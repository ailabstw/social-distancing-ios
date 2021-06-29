//
//  HintManager.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/6/9.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import CoreKit
import Foundation

class HintManager {
    static let shared = HintManager()

    @Persisted(userDefaultsKey: "presentedHintIDs", notificationName: HintManager.presentedHintIDsDidChangeNotification, defaultValue: [])
    private var presentedHintIDs: Set<Hint.ID>

    private let hints: [Hint] = [.qrCodeScannerHint, .dailySummaryHint]

    @Notified(notificationName: HintManager.pendingHintIDsDidChangeNotification)
    private(set) var pendingHints: [Hint] = []

    private init() {
        pendingHints = hints.filter { presentedHintIDs.contains($0.id) == false }
    }

    func didPresentHint(_ hint: Hint) {
        guard hints.map(\.id).contains(hint.id) else {
            return
        }

        presentedHintIDs.insert(hint.id)
        pendingHints.removeAll { $0 == hint }
    }

    #if DEBUG
    func resetPresentedHints() {
        presentedHintIDs.removeAll()
    }
    #endif
}

extension HintManager {
    private static let presentedHintIDsDidChangeNotification = Notification.Name("HintManager.presentedHintsDidChangeNotification")
    static let pendingHintIDsDidChangeNotification = Notification.Name("HintManager.pendingHintIDsDidChangeNotification")
}
