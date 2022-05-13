//
//  CertificateHolder.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/1.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation

struct CertificateHolder {
    let cose: Cose
    let cwt: CWT
    public let keyId: Data
    
    init(cwt: CWT, cose: Cose, keyId: Data) {
        self.cwt = cwt
        self.cose = cose
        self.keyId = keyId
    }
    
    public var certificate: DCCCert {
        cwt.certificate
    }
    
    public var issuedAt: Date? {
        if let i = cwt.iat?.asNumericDate() {
            return Date(timeIntervalSince1970: i)
        }
        return nil
    }
    
    public var issuer: String? {
        cwt.iss
    }
    
    public var expiresAt: Date? {
        if let i = cwt.exp?.asNumericDate() {
            return Date(timeIntervalSince1970: i)
        }
        return nil
    }
}
