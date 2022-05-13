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
    
    enum DisplayMode {
        case none
        case single
        case normal
    }
    
    enum Event {
        case none
        case scrollToIndex(Int)
        case itemRemoved(Int)
    }
    
    var models: [VaccinationCertificateDetailModel] = []
    
    @Observed(queue: .main)
    private(set) var event: Event = .none
    
    @Observed(queue: .main)
    var hasPrevCode: Bool = false
    
    @Observed(queue: .main)
    var hasNextCode: Bool = false
    
    private let dataStore: VaccinationCodeDataStore
    private let decoder = VaccinationCertificateDecoder()
    private let mapper: VaccinationCertificateModelMapper
    private(set) var currentCodeIndex: Int = 0
    private(set) var displayMode: DisplayMode = .normal
    
    init(code: String, dataStore: VaccinationCodeDataStore, mapper: VaccinationCertificateModelMapper) {
        self.dataStore = dataStore
        self.mapper = mapper
        
        dataStore.qrCodes.forEach {
            if let model = mapper.toDetailModel(by: $0) {
                self.models.append(model)
            }
        }
        
        if let index = dataStore.find(by: code) {
            currentCodeIndex = index
            currentIndexDidUpdate()
        } else {
            assertionFailure("WHY????")
        }
        
        displayMode = dataStore.qrCodes.count > 1 ? .normal : .single
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
        if let generatedDateString = model.generatedDateString {
            list.append(VaccinationCertificateDetailViewModel.Property(title: Localizations.VaccinationCertificateDetailViewModel.generatedDate,
                                                                       value: generatedDateString))
        }
        
        return list
    }
    
    func goNextCode() {
        currentCodeIndex += 1
        currentIndexDidUpdate()
    }
    
    func goPrevCode() {
        currentCodeIndex -= 1
        currentIndexDidUpdate()
    }
    
    func deleteCode(_ code: String) {
        guard let index = dataStore.find(by: code) else { return }
        models.remove(at: index)
        dataStore.delete(index: index)
        if dataStore.qrCodes.count == 0 {
            displayMode = .none
        } else {
            currentCodeIndex = max(min(dataStore.qrCodes.count - 1, currentCodeIndex), 0)
            currentIndexDidUpdate()
            displayMode = dataStore.qrCodes.count > 1 ? .normal : .single
        }
        event = .itemRemoved(index)
    }
    
    func didScrollToIndex(_ index: Int) {
        currentCodeIndex = index
        currentIndexDidUpdate()
    }
    
    private func currentIndexDidUpdate() {
        hasPrevCode = currentCodeIndex != 0
        hasNextCode = currentCodeIndex < dataStore.qrCodes.count - 1
        dataStore.updateCurrentIndex(currentCodeIndex)
        event = .scrollToIndex(currentCodeIndex)
    }
}

extension Localizations {
    enum VaccinationCertificateDetailViewModel {
        static let target = NSLocalizedString("VaccinationCertificateDetail.target", value: "Disease or agent targeted: ", comment: "")
        static let vaccine = NSLocalizedString("VaccinationCertificateDetail.vaccine", value: "Vaccine type:", comment: "")
        static let medicinalProduct = NSLocalizedString("VaccinationCertificateDetail.medicinalProduct", value: "Product: ", comment: "")
        static let manufacturer = NSLocalizedString("VaccinationCertificateDetail.manufacturer", value: "Manufacturer: ", comment: "")
        static let doses = NSLocalizedString("VaccinationCertificateDetail.doses", value: "Dose", comment: "")
        static let doseDate = NSLocalizedString("VaccinationCertificateDetail.doseDate", value: "Date of vaccination: ", comment: "")
        static let country = NSLocalizedString("VaccinationCertificateDetail.country", value: "Country of vaccination: ", comment: "")
        static let issuer = NSLocalizedString("VaccinationCertificateDetail.issuer", value: "Issuer: ", comment: "")
        static let uniqueIdentifier = NSLocalizedString("VaccinationCertificateDetail.uniqueIdentifier", value: "UVCI: ", comment: "")
        static let generatedDate = NSLocalizedString("VaccinationCertificateDetail.generatedDate", value: "Certificate generated on: ", comment: "")
    }
}
