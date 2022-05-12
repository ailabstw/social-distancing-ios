//
//  VaccinationCertificateRouter.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/17.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit

class VaccinationCertificateRouter {
    static func presentMainPage(_ from: UIViewController) {
        presentPage(from, target: VaccinationCertificateBuilder().getCardViewController())
    }
    
    static func presentDetailPage(_ from: UIViewController, code: String, delegate: VaccinationCertificateDetailDelegate? = nil) {
        let viewController = VaccinationCertificateBuilder().getDetailViewController(code: code, delegate: delegate)
        presentPage(from, target: viewController)
    }
    
    static func presentListPage(_ from: UIViewController) {
        presentPage(from, target: VaccinationCertificateBuilder().getListViewController())
    }
    
    static func presentQRCodeScanner(_ from: UIViewController) {
        presentPage(from, target: VaccinationCertificateBuilder().getScannerViewController())
    }
    
    static private func presentPage(_ from: UIViewController, target: UIViewController) {
        let navi = UINavigationController(rootViewController: target)
        navi.modalPresentationStyle = .fullScreen
        from.present(navi, animated: true, completion: nil)
    }
}

class VaccinationCertificateBuilder {
    func getCardViewController() -> VaccinationCertificateCardViewController {
        return VaccinationCertificateCardViewController(viewModel: getCardViewModel())
    }
    
    func getListViewController() -> VaccinationCertificateListViewController {
        return VaccinationCertificateListViewController(viewModel: getListViewModel())
    }
    
    func getDetailViewController(code: String, delegate: VaccinationCertificateDetailDelegate? = nil) -> VaccinationCertificateDetailViewController {
        return VaccinationCertificateDetailViewController(viewModel: getDetailViewModel(code: code), delegate: delegate)
    }
    
    func getScannerViewController() -> VaccinationCertificateScannerViewController {
        return VaccinationCertificateScannerViewController(viewModel: getScannerViewModel())
    }
    
    private func getCardViewModel() -> VaccinationCertificateCardViewModel {
        return VaccinationCertificateCardViewModel(codeDataStore: getCodeDataStore(),
                                                   qrCodeMapper: getQRCodeMapper())
    }
    
    private func getListViewModel() -> VaccinationCertificateListViewModel {
        return VaccinationCertificateListViewModel(dataStore: getCodeDataStore(),
                                                   mapper: getQRCodeMapper())
    }
    
    private func getDetailViewModel(code: String) -> VaccinationCertificateDetailViewModel {
        return VaccinationCertificateDetailViewModel(code: code,
                                                     dataStore: getCodeDataStore(),
                                                     mapper: getQRCodeMapper())
    }
    
    private func getScannerViewModel() -> VaccinationCertificateScannerViewModel {
        return VaccinationCertificateScannerViewModel(dataStore: getCodeDataStore(),
                                                      decoder: getCertificateDecoder())
    }
    
    private func getCodeDataStore() -> VaccinationCodeDataStore {
        return VaccinationCodeDataStoreProvider.shared
    }
    
    private func getQRCodeMapper() -> VaccinationCertificateModelMapper {
        return VaccinationCertificateModelMapper(metadataMapper: getMetadataMapper(), decoder: getCertificateDecoder())
    }
    
    private func getMetadataMapper() -> VaccinationCertifiateMetadataMapper {
        return VaccinationCertifiateMetadataMapper()
    }
    
    private func getCertificateDecoder() -> VaccinationCertificateDecoder {
        return VaccinationCertificateDecoder()
    }
}

