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
        case cancelled
    }

    @Observed(queue: .main)
    private(set) var title: String = Localizations.AlertCancellationViewModel.title
    
    @Observed(queue: .main)
    private(set) var status: Status = .notReady
    
    func didTapCheckbox(_ isSelected: Bool) {
        let newStatus: Status = isSelected ? .ready : .notReady
        transitStatus(to: newStatus)
    }
    
    func cancelAlert() {
        UserManager.shared.cancelAlert()
        transitStatus(to: .cancelled)
    }
    
    private func transitStatus(to newStatus: Status) {
        switch (status, newStatus) {
        case (.notReady, .ready),
             (.ready, .notReady),
             (.ready, .cancelled),
             (.cancelled, .notReady):
            status = newStatus
            
        default:
            break
        }
    }
}

extension Localizations {
    enum AlertCancellationViewModel {
        static let title = NSLocalizedString("AlertCancellationView.Title",
                                             value: "Reset Your Status",
                                             comment: "The title of alert cancellation view")
    }
}
