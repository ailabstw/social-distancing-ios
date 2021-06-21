//
//  AlertCancellationViewModel.swift
//  COVID19
//
//  Created by Shiva Huang on 2020/5/18.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import CoreKit
import Foundation
import PromiseKit

class AlertCancellationViewModel {
    enum Status {
        case notReady
        case ready
        case cancelling
        case cancelled(Bool)
    }

    @Observed(queue: .main)
    private(set) var title: String = Localizations.AlertCancellationViewModel.title
    
    @Observed(queue: .main)
    private(set) var status: Status = .notReady

    var minimumTestingDate: Date {
        Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -14, to: Date())!)
    }

    var maximumTestingDate: Date {
        Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
    }

    @Observed(queue: .main)
    var testingDate: Date? = nil {
        didSet {
            validate()
        }
    }
    
    @Observed(queue: .main)
    var passcode: String = "" {
        didSet {
            validate()
        }
    }
    
    private func transitStatus(to newStatus: Status) {
        switch (status, newStatus) {
        case (.notReady, .ready),
             (.ready, .notReady),
             (.ready, .cancelling),
             (.cancelling, .cancelled),
             (.cancelled, .notReady):
            status = newStatus
            
        default:
            break
        }
    }

    private func validate() {
        guard passcode.count == 8,
              let testingDate = testingDate,
              testingDate >= minimumTestingDate,
              testingDate < maximumTestingDate else {
            transitStatus(to: .notReady)
            return
        }

        transitStatus(to: .ready)
    }
    
    func cancelAlert() {
        guard passcode.count == 8,
              let testingDate = testingDate else {
            return
        }
        
        transitStatus(to: .cancelling)

        UserManager.shared.cancelAlert(using: passcode, before: Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: testingDate)!))
            .done { [weak self] in
                self?.transitStatus(to: .cancelled(true))
            }
            .catch { [weak self] (error) in
                logger.error("\(error)")
                self?.transitStatus(to: .cancelled(false))
            }
    }
}

extension Localizations {
    enum AlertCancellationViewModel {
        static let title = NSLocalizedString("AlertCancellationView.Title",
                                             comment: "The title of alert cancellation view")
    }
}
