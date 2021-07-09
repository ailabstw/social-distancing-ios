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

            // Delay 0.1 to wait banner resized.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.loadHints()
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

    let supportedHints: [Hint] = [.qrCodeScannerHint, .dailySummaryHint]

    var isHintPresentable: Bool = false {
        didSet {
            loadHints()
        }
    }

    @Observed(queue: .main)
    private(set) var pendingHints: [Hint] = []

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
            },
            HintManager.shared.$pendingHints { [unowned self] in
                self.loadHints()
            }
        ]

        updateStatus()
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

        case .inactive(.disabled), .inactive(.unauthorized), .unknown:
            ExposureManager.shared.setExposureNotificationEnabled(true) { (error) in
                if let error = error {
                    logger.error("\(error)")
                }
            }

        case .inactive(let reason):
            engageErrorHandler?(reason)
        }
    }

    func replayHints() {
        HintManager.shared.replayHints()
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

    private func loadHints() {
        guard isHintPresentable else {
            pendingHints = []
            return
        }

        pendingHints = HintManager.shared.pendingHints
            .filter {
                switch $0 {
                case .dailySummaryHint:
                    return [.risky, .clear].contains(self.status)

                case .qrCodeScannerHint:
                    return true

                default:
                    return false
                }
            }
    }
}

extension Localizations {
    enum RiskStatusViewModel {
        static let title = NSLocalizedString("RiskStatusView.Title",
                                             value: "Taiwan Social Distancing",
                                             comment: "The title of risk status view")

        enum Content {
            enum Scanning {
                static let title = NSLocalizedString("RiskStatusView.Content.Scanning.Title",
                                                     value: "Contact Tracing Evaluation",
                                                     comment: "The content title on risk status view when scanning")
            }

            enum Risky {
                static let title = NSLocalizedString("RiskStatusView.Content.Risky.Title",
                                                     value: "You have been in proximity with registered positive tests",
                                                     comment: "The content title on risk status view when risky")
                static let message = NSLocalizedString("RiskStatusView.Content.Risky.Message",
                                                       value: "Stay Calm: You have been identified as a close contact of a confirmed COVID-19 case, but that does NOT mean you are a confirmed case.\nSelf-Health Management: We advise you to conduct self-health management and be aware of your health conditions.\nHealth Conditions: If you have fever or respiratory symptoms, please contact your local health agency, or dial the toll-free hotline \"1922\" for testing arrangement.",
                                                       comment: "The content message on risk status view when risky")
            }

            enum NotTracing {
                static let title = NSLocalizedString("RiskStatusView.Content.NotTracing.Title",
                                                     value: "Exposure Notification is not enabled",
                                                     comment: "The content title on risk status view when not tracing")
                static let message = NSLocalizedString("RiskStatusView.Content.NotTracing.Message",
                                                       value: "Click the button below to enable exposure notification for possible contact with COVID-positive persons.",
                                                       comment: "The content message on risk status view when not tracing")
            }

            enum Clear {
                static let title = NSLocalizedString("RiskStatusView.Content.Clear.Title",
                                                     value: "No contact with registered positive tests",
                                                     comment: "The content title on risk status view when clear")
                static let message = NSLocalizedString("RiskStatusView.Content.Clear.Message",
                                                       value: "Please continue to maintain social distancing.",
                                                       comment: "The content message on risk status view when clear")
            }
        }
    }
}
