//
//  Vaccination.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/1.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation

struct Vaccination: Codable {
    public let disease: String
    public let vaccine: String
    public let medicinialProduct: String
    public let marketingAuthorizationHolder: String
    public let doseNumber: UInt64
    public let totalDoses: UInt64
    public let vaccinationDate: String
    public let country: String
    public let certificateIssuer: String
    public let certificateIdentifier: String
    
    private enum CodingKeys: String, CodingKey {
        case disease = "tg"
        case vaccine = "vp"
        case medicinialProduct = "mp"
        case marketingAuthorizationHolder = "ma"
        case doseNumber = "dn"
        case totalDoses = "sd"
        case vaccinationDate = "dt"
        case country = "co"
        case certificateIssuer = "is"
        case certificateIdentifier = "ci"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        disease = try container.decode(String.self, forKey: .disease).trimmed
        vaccine = try container.decode(String.self, forKey: .vaccine).trimmed
        medicinialProduct = try container.decode(String.self, forKey: .medicinialProduct).trimmed
        marketingAuthorizationHolder = try container.decode(String.self, forKey: .marketingAuthorizationHolder).trimmed
        
        if let dn = try? container.decode(Double.self, forKey: .doseNumber) {
            doseNumber = UInt64(dn)
        } else {
            doseNumber = try container.decode(UInt64.self, forKey: .doseNumber)
        }
        
        if let dn = try? container.decode(Double.self, forKey: .totalDoses) {
            totalDoses = UInt64(dn)
        } else {
            totalDoses = try container.decode(UInt64.self, forKey: .totalDoses)
        }
        
        vaccinationDate = try container.decode(String.self, forKey: .vaccinationDate).trimmed
        country = try container.decode(String.self, forKey: .country).trimmed
        certificateIssuer = try container.decode(String.self, forKey: .certificateIssuer).trimmed
        certificateIdentifier = try container.decode(String.self, forKey: .certificateIdentifier).trimmed
    }
    
}
