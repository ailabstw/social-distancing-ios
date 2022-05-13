//
//  VaccinationCertificateListViewModel.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/20.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import CoreKit
import Foundation

class VaccinationCertificateListViewModel: NSObject, VaccinationCodeDataStoreObserver {
    enum Event {
        case none
        case removeItem(code: String)
    }
    
    @Observed(queue: .main)
    var event: Event = .none
    
    var listModels: [VaccinationCertificateListModel] = []
    private let dataStore: VaccinationCodeDataStore
    private let mapper: VaccinationCertificateModelMapper
    
    init(dataStore: VaccinationCodeDataStore, mapper: VaccinationCertificateModelMapper) {
        self.dataStore = dataStore
        self.mapper = mapper
        super.init()
        
        refreshModels()
        
        dataStore.addObserver(self) { [weak self] event in
            switch event {
            case .delete(let code):
                self?.refreshModels()
                self?.event = .removeItem(code: code)
            case .update, .insert, .currentIndexUpdated:
                // ignore
                break
            }
        }
    }
    
    func moveItem(from: Int, to: Int) {
        let targetItem = listModels[from]
        listModels.remove(at: from)
        listModels.insert(targetItem, at: to)
        dataStore.update(qrCodes: listModels.map { $0.qrCode })
    }
    
    func didTapClose() {
        dataStore.removeObserver(self)
    }
    
    private func refreshModels() {
        listModels = dataStore.qrCodes.compactMap {
            mapper.toListModel(by: $0)
        }
    }
}
