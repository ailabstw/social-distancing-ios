//
//  EngagementStatistic.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/4/16.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import Foundation

struct EngagementStatistic: Codable {
    let engageDate: Date
    let uptime: TimeInterval
    let timestamp: Date
    let isEngaged: Bool

    var uptimeRatio: Double {
        let rate = min(max(timestamp.timeIntervalSince(engageDate) != 0.0 ? uptime / timestamp.timeIntervalSince(engageDate) : 1.0, 0.0), 1.0)

        return (rate * 1000).rounded(.toNearestOrAwayFromZero) / 1000.0
    }

    private enum CodingKeys: String, CodingKey {
        case engageDate
        case uptime
        case timestamp
        case isEngaged
    }

    init(engageDate: Date, uptime: TimeInterval, isEngaged: Bool = true) {
        self.engageDate = engageDate
        self.uptime = uptime
        self.timestamp = Date()
        self.isEngaged = isEngaged
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.engageDate = try container.decode(Date.self, forKey: .engageDate)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        if container.contains(.isEngaged) {
            // v1.2.0+ user.
            self.uptime = try container.decode(TimeInterval.self, forKey: .uptime)
            self.isEngaged = try container.decode(Bool.self, forKey: .isEngaged)
        } else {
            // Upgrade from v1.1.0 or v1.1.1.
            self.uptime = Date().timeIntervalSince(engageDate)
            self.isEngaged = true
        }
    }
}

// The `default` statistic is used only if no current engagement statistic existed. It means user is a new user, or first time launch for an upgraded user.
// For new user, create a default statistic value. For upgraded user, try to load old data to construct a statistic value.
extension EngagementStatistic {
    static let `default`: EngagementStatistic = EngagementStatistic()

    private init() {
        switch (UserPreferenceManager.shared.exposureNotificationEngageDate, ExposureManager.shared.exposureNotificationStatus) {
        case (.distantFuture, _), // New user
             (.distantPast, .active), // This should not happen
             (.distantPast, _): // Old user but never activated, treated as new user
            self.engageDate = .distantPast
            self.uptime = 0
            self.timestamp = Date()
            self.isEngaged = false

        case (let engageDate, .active), // Old user, load old data
             (let engageDate, _): // Old user but not activated now, assume uptime.
            self.engageDate = engageDate
            self.uptime = Date().timeIntervalSince(engageDate)
            self.timestamp = Date()
            self.isEngaged = true
        }
    }
}
