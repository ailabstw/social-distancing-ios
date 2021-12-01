//
//  Hint.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/6/9.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import Foundation

struct Hint {
    typealias ID = String

    let id: ID
    let title: String
    let subtitle: String?

    private init(id: ID, title: String, subtitle: String? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
    }
}

extension Hint: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension Hint {
    static let qrCodeScannerHint = Hint(id: "Hint.QRCodeScanner",
                                        title: Localizations.Hint.QRCodeScanner.title)
    static let dailySummaryHint = Hint(id: "Hint.DailySummary",
                                       title: Localizations.Hint.DailySummary.title)
    static let disableNoRiskNotificationHint = Hint(id: "Hint.DisableNoRiskNotification",
                                                    title: Localizations.Hint.DisableNoRiskNotification.title)
    static let replayHints = Hint(id: "Hint.ReplayHints",
                                  title: Localizations.Hint.ReplayHints.title)
}

extension Localizations {
    enum Hint {
        enum QRCodeScanner {
            static let title = NSLocalizedString("Hint.QRCodeScanner.Title",
                                                 value: "Add \"1922 SMS Contact Tracing\" Scanner",
                                                 comment: "Title for hint of adding 1922 SMS contact tracing scanner")
        }

        enum DailySummary {
            static let title = NSLocalizedString("Hint.DailySummary.Title",
                                                 value: "Add \"Daily Summary\" Page",
                                                 comment: "Title for hint of adding daily summary page")
        }
        
        enum DisableNoRiskNotification {
            static let title = NSLocalizedString("Hint.DisableNoRiskNotification.Title",
                                                 value: "You can turn off No Detected Notification from the Exposure Notification Settings.",
                                                 comment: "Title for hint of turning off No Detected Notification")
        }

        enum ReplayHints {
            static let title = NSLocalizedString("Hint.ReplayHints.Title",
                                                 value: "You can check the hints again from the menu.",
                                                 comment: "Title for hint of replaying hints")
        }
    }
}
