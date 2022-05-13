//
//  Cose.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/1.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import SwiftCBOR

struct Cose {
    private let type: CoseType
    let protectedHeader: CoseHeader
    let unprotectedHeader: CoseHeader?
    let payload: CBOR
    let signature: Data
    
    var keyId: Data? {
        var keyData: Data?
        if let unprotectedKeyId = unprotectedHeader?.keyId {
            keyData = Data(unprotectedKeyId)
        }
        if let protectedKeyId = protectedHeader.keyId {
            keyData = Data(protectedKeyId)
        }
        return keyData
    }
    
    init?(from data: Data) {
        guard let decodedData = try? CBOR.decode(data.bytes) else {
            return nil
        }
        
        let cose = try? CBORDecoder(input: data.bytes).decodeItem()?.asCose()
        
        if let cose = try? CBORDecoder(input: data.bytes).decodeItem()?.asCose(),
           let type = CoseType.from(data: data),
           let protectedHeader = CoseHeader(fromBytestring: cose.1[0]),
           let signature = cose.1[3].asBytes() {
            self.type = type
            self.protectedHeader = protectedHeader
            unprotectedHeader = CoseHeader(from: cose.1[1])
            payload = cose.1[2]
            self.signature = Data(signature)
        } else {
            guard let decodedDataList = decodedData.asList() else {
                return nil
            }
            
            let headerCBOR = decodedDataList[0]
            guard let header = CoseHeader(fromBytestring: headerCBOR) else { return nil }
            protectedHeader = header
            
            let text = decodedDataList[2]
            payload = text
            
            unprotectedHeader = nil
            // if not sign1 this is an array of signatures
            guard let sigBytes = decodedDataList[3].asBytes() else {
                return nil
            }
            signature = Data(sigBytes)
            // TODO: we should also support multiple signatures
            type = .sign1
        }
    }
    
}

extension Cose {
    struct CoseHeader {
        fileprivate let rawHeader: CBOR?
        let keyId: [UInt8]?
        let algorithm: Algorithm?
        
        enum Headers: Int {
            case keyId = 4
            case algorithm = 1
        }
        
        enum Algorithm: UInt64 {
            case es256 = 6 //-7
            case ps256 = 36 //-37
        }
        
        init?(fromBytestring cbor: CBOR){
            guard let cborMap = cbor.decodeBytestring()?.asMap(),
                  let algValue = cborMap[Headers.algorithm]?.asUInt64(),
                  let alg = Algorithm(rawValue: algValue) else { return nil }
            self.init(alg: alg, keyId: cborMap[Headers.keyId]?.asBytes(), rawHeader: cbor)
        }
        
        init?(from cbor: CBOR) {
            let cborMap = cbor.asMap()
            var alg: Algorithm?
            if let algValue = cborMap?[Headers.algorithm]?.asUInt64() {
                alg = Algorithm(rawValue: algValue)
            }
            self.init(alg: alg, keyId: cborMap?[Headers.keyId]?.asBytes())
        }
        
        private init(alg: Algorithm?, keyId: [UInt8]?, rawHeader: CBOR? = nil) {
            self.algorithm = alg
            self.keyId = keyId
            self.rawHeader = rawHeader
        }
    }
    
    enum CoseType: String {
        case sign1 = "Signature1"
        case sign = "Signature"
        
        static func from(data: Data) -> CoseType? {
            guard let cose = try? CBORDecoder(input: data.bytes).decodeItem()?.asCose() else {
                return nil
            }
            switch cose.0 {
            case .coseSign1Item: return .sign1
            case .coseSignItem: return .sign
            default:
                return nil
            }
        }
    }
}
