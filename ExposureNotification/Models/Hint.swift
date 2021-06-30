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
    }
}
