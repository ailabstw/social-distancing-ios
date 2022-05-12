//
//  DCCCert.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/1.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation

struct DCCCert: Decodable {
    let person: Person
    let dateOfBirth: String
    let version: String
    let vaccinations: [Vaccination]?
    
    private enum CodingKeys: String, CodingKey {
        case person = "nam"
        case dateOfBirth = "dob"
        case vaccinations = "v"
        case version = "ver"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        person = try container.decode(Person.self, forKey: .person)
        version = try container.decode(String.self, forKey: .version).trimmed
        dateOfBirth = try container.decode(String.self, forKey: .dateOfBirth).trimmed
        vaccinations = try? container.decode([Vaccination].self, forKey: .vaccinations)
    }
    
}
