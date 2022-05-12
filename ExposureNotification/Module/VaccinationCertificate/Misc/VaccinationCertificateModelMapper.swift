//
//  VaccinationCertificateModelMapper.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/12.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation

struct VaccinationCertificateModelMapper {
    private let metadataMapper: VaccinationCertifiateMetadataMapper
    private let decoder: VaccinationCertificateDecoder
    
    init(metadataMapper: VaccinationCertifiateMetadataMapper,
         decoder: VaccinationCertificateDecoder) {
        self.metadataMapper = metadataMapper
        self.decoder = decoder
    }
    
    func toModel(by qrCode: String) -> VaccinationCertificateCardModel? {
        switch decoder.decode(base45Encoded: qrCode) {
        case .success(let holder):
            guard let vaccination = holder.certificate.vaccinations?.first else {
                assertionFailure("Shouldn't be here")
                return nil
            }
            let person = holder.certificate.person
            return VaccinationCertificateCardModel(qrCode: qrCode,
                                                   displayname: formatName(person),
                                                   standardizedName: formatStandardizedName(person),
                                                   birthDate: transformDateFormat(holder.certificate.dateOfBirth),
                                                   doseDate: transformDateFormat(vaccination.vaccinationDate))
            
        case .failure(let error):
            print("decode failed, error: \(error)")
            return nil
        }
    }
    
    func toListModel(by qrCode: String) -> VaccinationCertificateListModel? {
        switch decoder.decode(base45Encoded: qrCode) {
        case .success(let holder):
            guard let vaccination = holder.certificate.vaccinations?.first else {
                assertionFailure("Shouldn't be here")
                return nil
            }
            let person = holder.certificate.person
            return VaccinationCertificateListModel(qrCode: qrCode,
                                                   displayname: formatName(person),
                                                   doseDate: transformDateFormat(vaccination.vaccinationDate))
            
        case .failure(let error):
            print("decode failed, error: \(error)")
            return nil
        }
    }
    
    func toDetailModel(by qrCode: String) -> VaccinationCertificateDetailModel? {
        switch decoder.decode(base45Encoded: qrCode) {
        case .success(let holder):
            guard let vaccination = holder.certificate.vaccinations?.first else {
                assertionFailure("Shouldn't be here")
                return nil
            }
            let person = holder.certificate.person
            
            return VaccinationCertificateDetailModel(qrCode: qrCode,
                                                     name: formatName(person),
                                                     standardizedName: formatStandardizedName(person),
                                                     uniqueIdentifier: vaccination.certificateIdentifier,
                                                     doses: "\(vaccination.doseNumber)/\(vaccination.totalDoses)",
                                                     medicinalProduct: metadataMapper.product(key: vaccination.medicinialProduct) ?? "",
                                                     manufacturer: metadataMapper.manufacturer(key: vaccination.marketingAuthorizationHolder) ?? "",
                                                     country: metadataMapper.country(key: vaccination.country) ?? "",
                                                     issuer: vaccination.certificateIssuer,
                                                     vaccineType: metadataMapper.prophylaxis(key: vaccination.vaccine) ?? "",
                                                     targetedDisease: metadataMapper.targetedDisease(key: vaccination.disease) ?? "",
                                                     doseDate: transformDateFormat(vaccination.vaccinationDate),
                                                     birthDate: transformDateFormat(holder.certificate.dateOfBirth))
        case .failure(let error):
            print("decode failed, error: \(error)")
            return nil
        }
    }
    
    private func formatName(_ person: Person) -> String {
        guard let firstUnicodeScalar = person.familyName?.first?.unicodeScalars.first else { return "\(person.familyName ?? "")\(person.givenName ?? "")" }
        if !CharacterSet.englishAlphanumeric.contains(firstUnicodeScalar) {
            return "\(person.familyName ?? "")\(person.givenName ?? "")"
        } else {
            return "\(person.givenName ?? "") \(person.familyName ?? "")"
        }
    }
    
    private func formatStandardizedName(_ person: Person) -> String {
        guard let firstUnicodeScalar = person.familyName?.first?.unicodeScalars.first else { return "\(person.standardizedFamilyName ?? "")\(person.standardizedGivenName ?? "")" }
        let replacedGivenName = person.standardizedGivenName?.replacingOccurrences(of: "<", with: "-") ?? ""
        let replacedFamilyName = person.standardizedFamilyName?.replacingOccurrences(of: "<", with: "-") ?? ""
        
        if !CharacterSet.englishAlphanumeric.contains(firstUnicodeScalar) {
            if replacedGivenName.isEmpty {
                return "\(replacedFamilyName)"
            } else {
                return "\(replacedFamilyName), \(replacedGivenName)"
            }
        } else {
            return "\(replacedGivenName) \(replacedFamilyName)"
        }
    }
    
    private func transformDateFormat(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else {
            return ""
        }
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

extension CharacterSet {
    static var englishAlphanumeric: CharacterSet {
        return CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    }
}
