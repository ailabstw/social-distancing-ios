//
//  CWT.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/1.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import SwiftCBOR

struct CWT {
    let iss: String?
    let exp: CBOR?
    let iat: CBOR?
    let certificate: DCCCert
    let decodedPayload: [CBOR: CBOR]
    
    enum PayloadKeys: Int {
        case iss = 1
        case iat = 6
        case exp = 4
        case lightCert = -250
        case hcert = -260
        
        enum HcertKeys: Int {
            case euHealthCertV1 = 1
        }
    }
    
    init?(from cbor: CBOR) {
        guard let decodedPayloadCwt = cbor.decodeBytestring()?.asMap() else {
            return nil
        }
        decodedPayload = decodedPayloadCwt
        
        iss = decodedPayload[PayloadKeys.iss]?.asString()
        exp = decodedPayload[PayloadKeys.exp]
        iat = decodedPayload[PayloadKeys.iat]
        
        if let hCertMap = decodedPayload[PayloadKeys.hcert]?.asMap(),
           let certData = hCertMap[PayloadKeys.HcertKeys.euHealthCertV1]?.asData(),
           let healthCert = try? CodableCBORDecoder().decode(DCCCert.self, from: certData) {
            certificate = healthCert
        } else {
            return nil
        }
    }
}
