//
//  VaccinationCertificateDecoder.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/1.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import Gzip

class VaccinationCertificateDecoder {
    enum DecodeError: Error {
        case invalidScheme
        case invalidBase45
        case decompressFailed
        case coseDeserializationFailed
    }
    
    private let scheme: String = "HC1:"
    
    func decode(base45Encoded string: String) -> Result<CertificateHolder, DecodeError> {
        guard let unprefixString = removeScheme(string) else { return .failure(.invalidScheme) }
        guard let decodedData = try? unprefixString.fromBase45() else { return .failure(.invalidBase45) }
        guard let decompressedData = decompress(decodedData) else { return .failure(.decompressFailed) }
        
        guard let cose = cose(from: decompressedData),
              let cwt = CWT(from: cose.payload),
              let keyId = cose.keyId else { return .failure(.coseDeserializationFailed) }
        
        return .success(CertificateHolder(cwt: cwt, cose: cose, keyId: keyId))
    }
    
    private func removeScheme(_ string: String) -> String? {
        guard string.starts(with: scheme) else { return nil }
        return String(string.dropFirst(scheme.count))
    }
    
    private func decompress(_ encodedData: Data) -> Data? {
        try? encodedData.gunzipped()
    }
    
    private func cose(from data: Data) -> Cose? {
        Cose(from: data)
    }
}
