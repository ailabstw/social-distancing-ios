//
//  UserManager.swift
//  COVID19
//
//  Created by Shiva Huang on 2020/4/7.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import CoreKit
import ExposureNotification
import Foundation
import PromiseKit
import UserNotifications

class UserManager {
    enum RiskStatus: String, Codable {
        case clear
        case risky
    }
    
    static let shared = UserManager()

    @Persisted(userDefaultsKey: "engagementStatistic", notificationName: UserManager.engagementStatisticDidChangeNotification, defaultValue:.default)
    private(set) var engagementStatistic: EngagementStatistic

    @Persisted(userDefaultsKey: "userRiskStatus", notificationName: UserManager.riskStatusDidChangeNotification, defaultValue: .clear)
    private(set) var riskStatus: RiskStatus {
        didSet {
            if oldValue == .clear && riskStatus == .risky {
                shouldNotifyRisky = true
            }
            showExposureNotificationIfNeeded(oldValue)
            setupDailyCheckNotification()
        }
    }

    @Persisted(userDefaultsKey: "riskSummary", notificationName: UserManager.riskSummaryDidChangeNotification, defaultValue: [:])
    private(set) var riskSummary: RiskSummary {
        didSet {
            logger.debug("riskSummary: \(riskSummary)")
            riskStatus = riskSummary.isRisky ? .risky : .clear
        }
    }
    
    @Persisted(userDefaultsKey: "shouldNotifyRisky", notificationName: shouldNotifyRiskyNotification, defaultValue: false)
    private var shouldNotifyRisky: Bool

    private var observers: [NSObjectProtocol] = []
    private let dailyCheckIdentifier = "daily-check-notification"
    
    private init() {
        observers.append(NotificationCenter.default.addObserver(forName: .willEnterForegroundNotification, object: nil, queue: nil) { [unowned self] (_) in
            self.updateEngagementStatistic()
            self.shouldNotifyRisky = false
        })
    }

    deinit {
        observers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }

    func updateEngagementStatistic() {
        // ExposureManager.shared.exposureNotificationStatus will be `.unknown` before activated.
        guard ExposureManager.shared.exposureNotificationStatus != .unknown else {
            return
        }

        let isEngaged: Bool = ExposureManager.shared.exposureNotificationStatus == .active

        let engageDate: Date = {
            if engagementStatistic.engageDate == .distantPast, ExposureManager.shared.exposureNotificationStatus == .active {
                return Date()
            } else {
                return engagementStatistic.engageDate
            }
        }()

        let uptime: TimeInterval = {
            guard isEngaged || engagementStatistic.isEngaged else {
                return engagementStatistic.uptime
            }

            return engagementStatistic.uptime + Date().timeIntervalSince(engagementStatistic.timestamp)
        }()

        let statistic = EngagementStatistic(engageDate: engageDate, uptime: uptime, isEngaged: isEngaged)
        logger.info("\(statistic)")

        engagementStatistic = statistic
    }

    func updateRiskSummary(_ summary: ENExposureDetectionSummary?) {
        riskSummary.updateRiskSummary(summary)
    }

    func cancelAlert() {
        riskSummary.updateBar(before: Date().enIntervalNumber)
    }

    func showExposureNotificationIfNeeded(_ oldValue: RiskStatus = .clear) {
        guard shouldSendNotification(newStatus: riskStatus,
                                     shouldNotifyRisky: shouldNotifyRisky,
                                     shouldNotifyEvenNoRisk: UserPreferenceManager.shared.shouldNotifyEvenNoRisk,
                                     date: Date()) else { return }

        let identifier = "exposure-risk"

        let content = UNMutableNotificationContent()
        content.title = Localizations.DetectionResultNotification.title
        content.body = riskStatus == .clear ? Localizations.DetectionResultNotification.Message.clear : Localizations.DetectionResultNotification.Message.risky
        content.sound = .default
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    logger.error("Error showing error user notification: \(error)")
                }
            }
        }
    }
    
    func shouldSendNotification(newStatus: RiskStatus, shouldNotifyRisky: Bool, shouldNotifyEvenNoRisk: Bool, date: Date) -> Bool {
        switch newStatus {
        case .risky:
            return shouldNotifyRisky
        case .clear:
            return (date.isBetween(18, 22) && shouldNotifyEvenNoRisk)
        }
    }
}

extension UserManager {
    static let engagementStatisticDidChangeNotification = Notification.Name("UserManager.engagementStatisticDidChange")
    static let riskStatusDidChangeNotification = Notification.Name("UserManager.riskStatusDidChange")
    static let riskSummaryDidChangeNotification = Notification.Name("UserManager.riskSummaryDidChange")
    static let shouldNotifyRiskyNotification = Notification.Name("UserManager.shouldNotifyRisky")
}

// MARK: - Daily Check Notification
extension UserManager {
    private func setupDailyCheckNotification() {
        if riskStatus == .risky || Date().isBetween(18, 22) {
            cancelNotification()
        } else {
            scheduleNotificationIfNeeded()
        }
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (list) in
            if !list.filter({ $0.identifier == self.dailyCheckIdentifier }).isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.dailyCheckIdentifier])
            }
        }
    }
    
    private func scheduleNotificationIfNeeded() {
        guard UserPreferenceManager.shared.shouldNotifyEvenNoRisk else {
            cancelNotification()
            return
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (list) in
            guard list.filter({ $0.identifier == self.dailyCheckIdentifier }).isEmpty else { return }
            
            let content = UNMutableNotificationContent()
            content.title = Localizations.DetectionResultNotification.title
            content.body = Localizations.DetectionResultNotification.Message.clear
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            dateComponents.hour = 22
               
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: self.dailyCheckIdentifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}

extension Date {
    func isBetween(_ start: Int, _ end: Int) -> Bool {
        let hour = Calendar.current.component(.hour, from: self)
        return (start..<end).contains(hour)
    }
}
