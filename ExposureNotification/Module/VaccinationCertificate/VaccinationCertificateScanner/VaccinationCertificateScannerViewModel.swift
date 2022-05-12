//
//  VaccinationCertificateScannerViewModel.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/15.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import AVFoundation
import CoreKit
import Foundation

class VaccinationCertificateScannerViewModel {
    enum ScanResult {
        case none
        case notFound
        case valid(String)
        case expired
        case duplicated
        case invalidFormat
        case countLimitExceeded
    }
    
    @Observed(queue: .main)
    var scanResult: ScanResult = .none
    
    private lazy var scanner: QRCodeScanner = {
        let scanner = QRCodeScanner()
        scanner.delegate = self
        return scanner
    }()
    
    private let dataStore: VaccinationCodeDataStore
    private let decoder: VaccinationCertificateDecoder
    
    var session: AVCaptureSession {
        scanner.session
    }
    
    init(dataStore: VaccinationCodeDataStore, decoder: VaccinationCertificateDecoder) {
        self.dataStore = dataStore
        self.decoder = decoder
        start()
    }
    
    func start() {
        scanner.start()
    }
    
    func stop() {
        scanner.stop()
    }
    
    func didFetchQRCodeFromImage(_ code: String?) {
        if let code = code {
            identifyQRCode(code)
        } else {
            scanResult = .notFound
        }
    }
    
    private func identifyQRCode(_ code: String) {
        if dataStore.find(by: code) != nil {
            scanResult = .duplicated
            return
        }
        
        switch decoder.decode(base45Encoded: code) {
        case .success(let holder):
            guard holder.certificate.vaccinations != nil else {
                scanResult = .invalidFormat
                return
            }
            
            if let expireDate = holder.expiresAt, Date() > expireDate {
                scanResult = .expired
            } else {
                if dataStore.insert(code) {
                    scanResult = .valid(code)
                } else {
                    scanResult = .countLimitExceeded
                }
            }
        case .failure:
            scanResult = .invalidFormat
        }
    }
}

extension VaccinationCertificateScannerViewModel: QRCodeScannerDelegate {
    func didCaptureOthers() {
        scanResult = .none
    }
    
    func didCaptureQRCode(_ code: String) {
        identifyQRCode(code)
    }
    
}
