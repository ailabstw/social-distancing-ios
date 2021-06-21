//
//  ExposureConfiguration.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/4/1.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import ExposureNotification
import Foundation

struct ExposureConfiguration: Codable {
    // API V2 Keys
    let immediateDurationWeight: Double
    let nearDurationWeight: Double
    let mediumDurationWeight: Double
    let otherDurationWeight: Double
    let infectiousnessForDaysSinceOnsetOfSymptoms: [String: Int]
    let infectiousnessStandardWeight: Double
    let infectiousnessHighWeight: Double
    let reportTypeConfirmedTestWeight: Double
    let reportTypeConfirmedClinicalDiagnosisWeight: Double
    let reportTypeSelfReportedWeight: Double
    let reportTypeRecursiveWeight: Double
    let reportTypeNoneMap: Int
    // API V1 Keys
    let minimumRiskScore: ENRiskScore
    let attenuationDurationThresholds: [Int]
    let attenuationLevelValues: [ENRiskLevelValue]
    let daysSinceLastExposureLevelValues: [ENRiskLevelValue]
    let durationLevelValues: [ENRiskLevelValue]
    let transmissionRiskLevelValues: [ENRiskLevelValue]
}
