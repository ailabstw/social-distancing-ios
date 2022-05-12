//
//  VaccinationCertificateDetailViewModel.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/6.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import CoreKit
import Foundation

class VaccinationCertificateDetailViewModel {
    struct Property {
        let title: String
        let value: String
    }
    
    @Observed(queue: .main)
    private(set) var code: String = ""
    
    @Observed(queue: .main)
    private(set) var model: VaccinationCertificateDetailModel? = nil
    
    @Observed(queue: .main)
    private(set) var vaccinationProperties: [Property] = []
    private let dataStore: VaccinationCodeDataStore
    private let decoder = VaccinationCertificateDecoder()
    private let mapper: VaccinationCertificateModelMapper
    private var currentCodeIndex: Int = 0
    
    @Observed(queue: .main)
    var hasPrevCode: Bool = false
    
    @Observed(queue: .main)
    var hasNextCode: Bool = false
    
    init(code: String, dataStore: VaccinationCodeDataStore, mapper: VaccinationCertificateModelMapper) {
        self.code = code
        self.dataStore = dataStore
        self.mapper = mapper
        self.model = mapper.toDetailModel(by: code)
        if let model = self.model {
            vaccinationProperties = buildVaccinationProperties(by: model)
        }
        
        if let index = dataStore.find(by: code) {
            currentCodeIndex = index
            currentIndexDidUpdate()
        } else {
            assertionFailure("WHY????")
        }
    }
    
    func goNextCode() {
        currentCodeIndex += 1
        currentIndexDidUpdate()
        
        code = dataStore.qrCodes[currentCodeIndex]
        currentCodeDidUpdate()
    }
    
    func goPrevCode() {
        currentCodeIndex -= 1
        currentIndexDidUpdate()
        
        code = dataStore.qrCodes[currentCodeIndex]
        currentCodeDidUpdate()
    }
    
    func deleteCurrentCode() {
        dataStore.delete(code: code)
    }
    
    private func currentCodeDidUpdate() {
        self.model = mapper.toDetailModel(by: code)
        if let model = self.model {
            vaccinationProperties = buildVaccinationProperties(by: model)
        }
    }
    
    private func currentIndexDidUpdate() {
        hasPrevCode = currentCodeIndex != 0
        hasNextCode = currentCodeIndex < dataStore.qrCodes.count - 1
    }
    
    func buildVaccinationProperties(by model: VaccinationCertificateDetailModel) -> [VaccinationCertificateDetailViewModel.Property] {
        var list = [VaccinationCertificateDetailViewModel.Property]()
        
        list.append(VaccinationCertificateDetailViewModel.Property(title: Localizations.VaccinationCertificateDetailViewModel.target,
                                                                   value: model.targetedDisease))
        list.append(VaccinationCertificateDetailViewModel.Property(title: Localizations.VaccinationCertificateDetailViewModel.vaccine,
                                                                   value: model.vaccineType))
        list.append(VaccinationCertificateDetailViewModel.Property(title: Localizations.VaccinationCertificateDetailViewModel.medicinalProduct,
                                                                   value: model.medicinalProduct))
        list.append(VaccinationCertificateDetailViewModel.Property(title: Localizations.VaccinationCertificateDetailViewModel.manufacturer,
                                                                   value: model.manufacturer))
        list.append(VaccinationCertificateDetailViewModel.Property(title: Localizations.VaccinationCertificateDetailViewModel.doses,
                                                                   value: model.doses))
        list.append(VaccinationCertificateDetailViewModel.Property(title: Localizations.VaccinationCertificateDetailViewModel.doseDate,
                                                                   value: model.doseDate))
        list.append(VaccinationCertificateDetailViewModel.Property(title: Localizations.VaccinationCertificateDetailViewModel.country,
                                                                   value: model.country))
        list.append(VaccinationCertificateDetailViewModel.Property(title: Localizations.VaccinationCertificateDetailViewModel.issuer,
                                                                   value: model.issuer))
        list.append(VaccinationCertificateDetailViewModel.Property(title: Localizations.VaccinationCertificateDetailViewModel.uniqueIdentifier,
                                                                   value: model.uniqueIdentifier))
        
        return list
    }
}

extension Localizations {
    enum VaccinationCertificateDetailViewModel {
        static let target = NSLocalizedString("VaccinationCertificateDetail.target", value: "Disease or agent targeted: ", comment: "")
        static let vaccine = NSLocalizedString("VaccinationCertificateDetail.vaccine", value: "Vaccine type:", comment: "")
        static let medicinalProduct = NSLocalizedString("VaccinationCertificateDetail.medicinalProduct", value: "Product: ", comment: "")
        static let manufacturer = NSLocalizedString("VaccinationCertificateDetail.manufacturer", value: "Manufacturer: ", comment: "")
        static let doses = NSLocalizedString("VaccinationCertificateDetail.doses", value: "Dose", comment: "")
        static let doseDate = NSLocalizedString("VaccinationCertificateDetail.doseDate", value: "Date of vacination: ", comment: "")
        static let country = NSLocalizedString("VaccinationCertificateDetail.country", value: "Country of vaccination: ", comment: "")
        static let issuer = NSLocalizedString("VaccinationCertificateDetail.issuer", value: "Issuer: ", comment: "")
        static let uniqueIdentifier = NSLocalizedString("VaccinationCertificateDetail.uniqueIdentifier", value: "UVCI", comment: "")
    }
}
