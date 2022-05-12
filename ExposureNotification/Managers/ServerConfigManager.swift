//
//  ServerConfigManager.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/20.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import CoreKit
import Foundation
import PromiseKit
import UIKit

class ServerConfigManager {
    static let shared = ServerConfigManager()
    
    private let apiManager = APIManager.shared
    
    @Persisted(userDefaultsKey: "configuredText", notificationName: ServerConfigManager.configuredTextDidChangeNotification, defaultValue: nil)
    private(set) var configuredText: ServerConfigText?
    
    @Persisted(userDefaultsKey: "alarmPeriod", notificationName: ServerConfigManager.alarmPeriodDidChangeNotification, defaultValue: 7)
    private(set) var alarmPeriod: Int
    
    private init() {}
    
    func fetchData() {
        fetchAsset()
        fetchConfig()
    }
    
    private func fetchAsset() {
        guard let langCode = Bundle.main.preferredLocalizations.first else {
            assertionFailure()
            return
        }
        
        apiManager.request(ConfigEndpoint.healthEducation(lang: ConfigEndpoint.LanguageCode(langCode)))
            .done { [weak self] (result: ServerConfigText) in
                self?.configuredText = result
            }
            .catch { error in
                logger.error("\(error)")
            }
    }
    
    private func fetchConfig() {
        apiManager.request(ConfigEndpoint.config)
            .done { [weak self] (response: ServerConfigResponse) in
                self?.alarmPeriod = response.alarmPeriod
            }
            .catch { error in
                logger.error("\(error)")
            }
    }
    
}

extension ServerConfigManager {
    static let configuredTextDidChangeNotification = Notification.Name("ServerConfigManager.configuredTextDidChangeNotification")
    static let alarmPeriodDidChangeNotification = Notification.Name("ServerConfigManager.alarmPeriodDidChangeNotification")
}

struct ServerConfigText: Codable {
    let riskyDetail: String?
    let riskyDetailHeaderSeparator: String?
    let alertCancellationInfo: String?
    
    private enum CodingKeys: String, CodingKey {
        case riskyDetail = "risky_detail"
        case riskyDetailHeaderSeparator = "risky_detail_header_separator"
        case alertCancellationInfo = "alert_cancellation_info"
    }
}

struct ServerConfigResponse: Codable {
    let alarmPeriod: Int
    
    private enum CodingKeys: String, CodingKey {
        case alarmPeriod = "alarm_period"
    }
}
