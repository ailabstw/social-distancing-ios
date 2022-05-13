//
//  CBORExtensions.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/1.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import SwiftCBOR

extension CBOR {
    func unwrap() -> Any? {
        switch self {
        case let .simple(value): return value
        case let .boolean(value): return value
        case let .byteString(value): return value
        case let .date(value): return value
        case let .double(value): return value
        case let .float(value): return value
        case let .half(value): return value
        case let .tagged(tag, cbor): return (tag, cbor)
        case let .array(array): return array
        case let .map(map): return map
        case let .utf8String(value): return value
        case let .negativeInt(value): return value
        case let .unsignedInt(value): return value
        default:
            return nil
        }
    }
    
    func asNumericDate() -> Double? {
        switch self {
        case let .double(value): return Double(value)
        case let .float(value): return Double(value)
        case let .half(value): return Double(value)
        case let .negativeInt(value): return Double(value)
        case let .unsignedInt(value): return Double(value)
        default:
            return nil
        }
    }
    
    func asBytes() -> [UInt8]? {
        unwrap() as? [UInt8]
    }
    
    func asData() -> Data {
        Data(encode())
    }
    
    func asList() -> [CBOR]? {
        unwrap() as? [CBOR]
    }
    
    func asCose() -> (CBOR.Tag, [CBOR])? {
        guard let rawCose = unwrap() as? (CBOR.Tag, CBOR),
              let cosePayload = rawCose.1.asList() else { return nil }
        return (rawCose.0, cosePayload)
    }
    
    func asMap() -> [CBOR:CBOR]? {
        return self.unwrap() as? [CBOR:CBOR]
    }
    
    func decodeBytestring() -> CBOR? {
        guard let bytestring = self.asBytes(),
              let decoded = try? CBORDecoder(input: bytestring).decodeItem() else {
                  return nil
              }
        return decoded
    }
    
    func asInt64() -> Int64? {
        return self.unwrap() as? Int64
    }
    
    func asUInt64() -> UInt64? {
        return self.unwrap() as? UInt64
    }
    
    func asString() -> String? {
        return self.unwrap() as? String
    }
}

extension CBOR.Tag {
    public static let coseSign1Item = CBOR.Tag(rawValue: 18)
    public static let coseSignItem = CBOR.Tag(rawValue: 98)
}

extension Dictionary where Key == CBOR {
    subscript<Index: RawRepresentable>(index: Index) -> Value? where Index.RawValue == String {
        return self[CBOR(stringLiteral: index.rawValue)]
    }
    
    subscript<Index: RawRepresentable>(index: Index) -> Value? where Index.RawValue == Int {
        return self[CBOR(integerLiteral: index.rawValue)]
    }
}
