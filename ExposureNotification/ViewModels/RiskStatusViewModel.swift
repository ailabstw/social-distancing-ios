//
//  RiskStatusViewModel.swift
//  COVID19
//
//  Created by Shiva Huang on 2020/4/2.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import CoreKit
import Foundation

class RiskStatusViewModel {
    enum Status {
        case risky
        case clear
        case notTracing
        case unknown
    }

    @Observed(queue: .main)
    private(set) var title: String = Localizations.RiskStatusViewModel.title
    
    @Observed(queue: .main)
    private(set) var status: Status = .unknown {
        didSet {
            switch status {
            case .risky:
                diagnosis = (Localizations.RiskStatusViewModel.Content.Risky.title, Localizations.RiskStatusViewModel.Content.Risky.message)

            case .notTracing:
                diagnosis = (Localizations.RiskStatusViewModel.Content.NotTracing.title, Localizations.RiskStatusViewModel.Content.NotTracing.message)

            case .clear:
                diagnosis = (Localizations.RiskStatusViewModel.Content.Clear.title, Localizations.RiskStatusViewModel.Content.Clear.message)

            case .unknown:
                diagnosis = ("", "")
            }
        }
    }
    
    @Observed(queue: .main)
    private(set) var riskStatus: UserManager.RiskStatus = UserManager.shared.riskStatus {
        didSet {
            updateStatus()
        }
    }

    @Observed(queue: .main)
    private(set) var exposureNotificationStatus: ExposureManager.Status = ExposureManager.shared.exposureNotificationStatus {
        didSet {
            updateStatus()
        }
    }

    @Observed(queue: .main)
    private(set) var engagementStatistic: EngagementStatistic = UserManager.shared.engagementStatistic

    @Observed(queue: .main)
    private(set) var lastCheckedDateTime: Date = ExposureManager.shared.dateLastPerformedExposureDetection
    
    @Observed(queue: .main)
    private(set) var diagnosis: (banner: String, detail: String) = ("", "")

    // FIXME: It's not a good implementation, needs refactoring.
    @Observed(queue: .main)
    private(set) var appUpdatesAvailable: Bool = false {
        didSet {
            if appUpdatesAvailable {
                appUpdatesHandler?()
            }
        }
    }

    var engageErrorHandler: ((ExposureManager.InactiveReason) -> Void)?

    var appUpdatesHandler: (() -> Void)?

    private var observers: [NSObjectProtocol] = []
    
    init() {
        observers = [
            ExposureManager.shared.$exposureNotificationStatus { [unowned self] in
                self.exposureNotificationStatus = ExposureManager.shared.exposureNotificationStatus
            },
            UserManager.shared.$riskStatus { [unowned self] in
                self.riskStatus = UserManager.shared.riskStatus
            },
            UserManager.shared.$engagementStatistic { [unowned self] in
                self.engagementStatistic = UserManager.shared.engagementStatistic
            },
            UserPreferenceManager.shared.$isNewVersionAvailable { [unowned self] in
                self.appUpdatesAvailable = UserPreferenceManager.shared.isNewVersionAvailable
            },
            ExposureManager.shared.$dateLastPerformedExposureDetection { [unowned self] in
                self.lastCheckedDateTime = ExposureManager.shared.dateLastPerformedExposureDetection
            }
        ]
    }
    
    deinit {
        observers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }

    func engageExposureNotification() {
        switch ExposureManager.shared.exposureNotificationStatus {
        case .active:
            // Nothing to do.
            break

        case .inactive(.disabled), .unknown:
            ExposureManager.shared.setExposureNotificationEnabled(true) { (error) in
                if let error = error {
                    logger.error("\(error)")
                }
            }

        case .inactive(let reason):
            engageErrorHandler?(reason)
        }
    }

    #if DEBUG
    func debugSetRiskStatus(_ status: UserManager.RiskStatus) {
        riskStatus = status
    }
    #endif

    private func updateStatus() {
        switch (exposureNotificationStatus, riskStatus) {
        case (_, .risky):
            status = .risky

        case (.active, .clear):
            status = .clear

        case (.inactive, .clear):
            status = .notTracing

        case (.unknown, _):
            status = .unknown
        }
    }
}

extension Localizations {
    enum RiskStatusViewModel {
        static let title = NSLocalizedString("RiskStatusView.Title",
                                             comment: "The title of risk status view")

        enum Content {
            enum Scanning {
                static let title = NSLocalizedString("RiskStatusView.Content.Scanning.Title",
                                                     comment: "The content title on risk status view when scanning")
            }

            enum Risky {
                static let title = NSLocalizedString("RiskStatusView.Content.Risky.Title",
                                                     comment: "The content title on risk status view when risky")
                static let message = NSLocalizedString("RiskStatusView.Content.Risky.Message",
                                                       comment: "The content message on risk status view when risky")
            }

            enum NotTracing {
                static let title = NSLocalizedString("RiskStatusView.Content.NotTracing.Title",
                                                     comment: "The content title on risk status view when not tracing")
                static let message = NSLocalizedString("RiskStatusView.Content.NotTracing.Message",
                                                       comment: "The content message on risk status view when not tracing")
            }

            enum Clear {
                static let title = NSLocalizedString("RiskStatusView.Content.Clear.Title",
                                                     comment: "The content title on risk status view when clear")
                static let message = NSLocalizedString("RiskStatusView.Content.Clear.Message",
                                                       comment: "The content message on risk status view when clear")
            }
        }
    }
}
