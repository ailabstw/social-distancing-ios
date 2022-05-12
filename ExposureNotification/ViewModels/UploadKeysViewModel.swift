//
//  UploadKeysViewModel.swift
//  COVID19
//
//  Created by Shiva Huang on 2020/5/18.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import CoreKit
import Foundation
import PromiseKit

class UploadKeysViewModel {
    enum Status {
        case notReady
        case ready
        case uploading
        case uploaded(UploadResult)
    }
    
    enum UploadResult {
        case success
        case verifyAPIFailed
        case couldNotGetKeys
        case otherAPIFailed
    }

    @Observed(queue: .main)
    private(set) var title: String = Localizations.UploadKeysViewModel.title
    
    @Observed(queue: .main)
    private(set) var status: Status = .notReady
    
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
             (.uploaded, .notReady):
            status = newStatus
            
        default:
            break
        }
    }
    
    func uploadKeys() {
        guard passcode.count == 8 else {
            return
        }
        
        transitStatus(to: .uploading)

        ExposureManager.shared.postDiagnosisKeys(using: passcode, from: startDate, to: endDate)
            .done { (result) in
                if result {
                    self.transitStatus(to: .uploaded(.success))
                } else {
                    self.transitStatus(to: .uploaded(.otherAPIFailed))
                }
                
            }
            .catch { (error) in
                logger.error("\(error)")
                if let uploadError = error as? ExposureManager.UploadError {
                    switch uploadError {
                    case .keysNotFound:
                        self.transitStatus(to: .uploaded(.couldNotGetKeys))
                    case .verifyFailed:
                        self.transitStatus(to: .uploaded(.verifyAPIFailed))
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
