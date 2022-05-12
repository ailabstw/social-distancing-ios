//
//  VaccinationCertifiateMetadataMapper.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/1.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation

class VaccinationCertifiateMetadataMapper {
    private let metadata: Metadata
    
    init() {
        guard let resource = Bundle.main.path(forResource: "metadata", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: resource), options: .mappedIfSafe),
              let metadata = try? JSONDecoder().decode(Metadata.self, from: data) else {
                  fatalError()
              }
        self.metadata = metadata
    }
    
    func targetedDisease(key: String) -> String? {
        metadata.targetedDisease.display(key: key)
    }
    
    func country(key: String) -> String? {
        metadata.countryCode.display(key: key)
    }
    
    func manufacturer(key: String) -> String? {
        metadata.mahManf.display(key: key)
    }
    
    func prophylaxis(key: String) -> String? {
        metadata.prophylaxis.display(key: key)
    }
    
    func product(key: String) -> String? {
        metadata.medicinalProduct.display(key: key)
    }
    
}

class Metadata: Codable {
    let targetedDisease: ValueSet
    let countryCode: ValueSet
    let mahManf: ValueSet
    let medicinalProduct: ValueSet
    let prophylaxis: ValueSet
    
    struct ValueSet: Codable {
        let valueSetId: String?
        let valueSetDate: String?
        let valueSetValues: [String: ValueSetItem]

        init() {
            valueSetId = nil
            valueSetDate = nil
            valueSetValues = [:]
        }

        func display(key: String?) -> String? {
            guard let k = key,
                  let p = valueSetValues[k],
                  let name = p.display
            else {
                let empty = key?.isEmpty ?? true
                return empty ? nil : key
            }

            return name
        }
    }
    
    struct ValueSetItem: Codable {
        let display: String?
        let lang: String?
        let active: Bool?
        let system: String?
        let version: String?
    }
}
