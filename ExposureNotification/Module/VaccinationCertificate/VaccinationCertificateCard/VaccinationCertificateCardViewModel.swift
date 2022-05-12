//
//  VaccinationCertificateCardViewModel.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/23.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import CoreKit
import Foundation

class VaccinationCertificateCardViewModel: NSObject, VaccinationCodeDataStoreObserver {
    enum State {
        case empty
        case normal
    }
    
    enum Event {
        case none
        case scrollToIndex(Int)
        case refreshCards
        case cardsLimitExceeded
    }
    
    @Observed(queue: .main)
    var state: State = .empty
    
    @Observed(queue: .main)
    var event: Event = .none
    
    private(set) var cardModels = [VaccinationCertificateCardModel]() {
        didSet {
            state = cardModels.isEmpty ? .empty : .normal
        }
    }
    
    private let codeDataStore: VaccinationCodeDataStore
    private let qrCodeMapper: VaccinationCertificateModelMapper
    
    init(codeDataStore: VaccinationCodeDataStore, qrCodeMapper: VaccinationCertificateModelMapper) {
        self.codeDataStore = codeDataStore
        self.qrCodeMapper = qrCodeMapper
        
        super.init()
        
        codeDataStore.addObserver(self) { [weak self] event in
            switch event {
            case .insert(let code):
                self?.refreshCards()
                if let index = codeDataStore.find(by: code) {
                    self?.event = .scrollToIndex(index)
                }
            case .delete:
                self?.refreshCards()
            case .update:
                self?.refreshCards()
            case .limitExceeded:
                self?.event = .cardsLimitExceeded
            }
        }
    }
    
    func didTapClose() {
        codeDataStore.removeObserver(self)
    }
    
    func viewWillAppear() {
        refreshCards()
    }
    
    private func refreshCards() {
        cardModels = codeDataStore.qrCodes.compactMap {
            qrCodeMapper.toModel(by: $0)
        }
        event = .refreshCards
    }
}
