//
//  UploadKeysViewModel.swift
//  COVID19
//
//  Created by Shiva Huang on 2020/5/18.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import CoreKit
import ExposureNotification
import Foundation
import PromiseKit


class UploadKeysViewModel {
    enum Status {
        case notReady
        case ready
        case uploading
        case uploaded(UploadResult)
        case waitForRetry(RetryReason)
    }
    
    enum UploadResult {
        case success
        case verifyAPIFailed
        case otherAPIFailed
    }
    
    enum RetryReason {
        case couldNotGetKeys
        case userDenied
    }

    @Observed(queue: .main)
    private(set) var title: String = Localizations.UploadKeysViewModel.title
    
    @Observed(queue: .main)
    private(set) var status: Status = .notReady
    
    private var verifiedToken: String?
    private var verifiedSymptonDate: Date?
    
    var exposureNotificationEnabled: Bool {
        return ExposureManager.shared.exposureNotificationStatus == .active
    }

    var minimumStartDate: Date {
        Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -14, to: Date())!)
    }

    var maximumEndDate: Date {
        Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
    }

    @Observed(queue: .main)
    var startDate: Date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -14, to: Date())!) {
        didSet {
            guard endDate > startDate else {
                endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
                return
            }
        }
    }

    @Observed(queue: .main)
    var endDate: Date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!) {
        didSet {
            guard startDate < endDate else {
                startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)!
                return
            }
        }
    }
    
    @Observed(queue: .main)
    var passcode: String = "" {
        didSet {
            guard exposureNotificationEnabled else { return }
            transitStatus(to: passcode.count == 8 ? .ready: .notReady)
        }
    }
    
    private func transitStatus(to newStatus: Status) {
        switch (status, newStatus) {
        case (.notReady, .ready),
            (.ready, .notReady),
            (.ready, .uploading),
            (.uploading, .uploaded),
            (.uploading, .waitForRetry),
            (.uploaded, .notReady),
            (.waitForRetry, .uploading):
            status = newStatus
            
        default:
            break
        }
    }
    
    func uploadKeys() {
        guard passcode.count == 8 else {
            return
        }
        
        firstly {
            Promise { (seal) in
                if case .waitForRetry = status {
                    self.transitStatus(to: .uploading)
                    seal.fulfill(true)
                } else {
                    self.transitStatus(to: .uploading)
                    ExposureManager.shared.verifyCode(using: passcode)
                        .done { response in
                            self.verifiedToken = response.token
                            self.verifiedSymptonDate = response.symptomDate
                            seal.fulfill(true)
                        }
                        .catch { error in
                            seal.reject(error)
                        }
                }
            }
        }
        .then { (success: Bool) in
            ExposureManager.shared.checkDiagnosisKeys(from: self.startDate, to: self.endDate)
        }
        .then { (keys: [ENTemporaryExposureKey]) in
            ExposureManager.shared.uploadDiagnosisKeys(token: self.verifiedToken!, symptomDate: self.verifiedSymptonDate!, keys: keys)
        }
        .done { (success: Bool) in
            if success {
                self.transitStatus(to: .uploaded(.success))
            } else {
                self.transitStatus(to: .uploaded(.otherAPIFailed))
            }
        }
        .catch { error in
            logger.error("\(error)")
            if let uploadError = error as? ExposureManager.UploadError {
                switch uploadError {
                case .keysNotFound:
                    self.transitStatus(to: .waitForRetry(.couldNotGetKeys))
                case .verifyFailed:
                    self.transitStatus(to: .uploaded(.verifyAPIFailed))
                case .userDenied:
                    self.transitStatus(to: .waitForRetry(.userDenied))
                case .unknown:
                    self.transitStatus(to: .uploaded(.otherAPIFailed))
                }
            } else {
                self.transitStatus(to: .uploaded(.otherAPIFailed))
            }
        }
    }
}

extension Localizations {
    enum UploadKeysViewModel {
        static let title = NSLocalizedString("UploadKeysView.Title",
                                             value: "Upload Anonymous IDs",
                                             comment: "The title of upload keys view")
    }
}
