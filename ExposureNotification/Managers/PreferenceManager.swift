//
//  PreferenceManager.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/2/26.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import CoreKit
import Foundation
import Updates

class UserPreferenceManager {
    static let shared = UserPreferenceManager()

    private init() {
        checkAppUpdates()
    }

    @Persisted(userDefaultsKey: "isIntroductionWatched", notificationName: UserPreferenceManager.isIntroductionWatchedDidChangeNotification, defaultValue: false)
    var isIntroductionWatched: Bool

    // Possible value for users from 1.0.0:
    // - Activated: A date in past.
    // - Not Activated: `.distantPast`.
    // Value for new users:
    // - `.distantFuture`
    @Persisted(userDefaultsKey: "exposureNotificationEngageDate", notificationName: UserPreferenceManager.exposureNotificationEngageDateDidChangeNotification, defaultValue: .distantFuture)
    private(set) var exposureNotificationEngageDate: Date

    @Persisted(userDefaultsKey: "isNewVersionAvailable", notificationName: UserPreferenceManager.isNewVersionAvailableDidChangeNotification, defaultValue: false)
    private(set) var isNewVersionAvailable: Bool
    
    @Persisted(userDefaultsKey: "shouldNotifyEvenNoRisk", notificationName: UserPreferenceManager.shouldNotifyEvenNoRiskNotification, defaultValue: true)
    var shouldNotifyEvenNoRisk: Bool

    func checkAppUpdates() {
        Updates.comparingVersions = .patch
        Updates.updatingMode = .automatically
        Updates.notifying = .always
        Updates.appStoreId = "1554431836"

        Updates.checkForUpdates { [unowned self] result in
            switch result {
            case .available:
                self.isNewVersionAvailable = true

            case .none:
                self.isNewVersionAvailable = false
            }
        }
    }
}

extension UserPreferenceManager {
    static let isIntroductionWatchedDidChangeNotification = Notification.Name("UserPreferenceManager.isIntroductionWatchedDidChangeNotification")
    static let exposureNotificationEngageDateDidChangeNotification = Notification.Name("UserPreferenceManager.exposureNotificationEngageDateDidChangeNotification")
    static let isNewVersionAvailableDidChangeNotification = Notification.Name("UserPreferenceManager.isNewVersionAvailableDidChangeNotification")
    static let shouldNotifyEvenNoRiskNotification = Notification.Name("UserPreferenceManager.shouldNotifyEvenNoRiskNotification")
}
