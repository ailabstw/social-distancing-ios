//
//  UserManagerTests.swift
//  ExposureNotificationTests
//
//  Created by Chuck on 2022/5/30.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import XCTest
@testable import ExposureNotificationApp

class UserManagerTests: XCTestCase {
    func testShouldNotify_whenStatusChangeToRiskyAndShouldNotifyRiskyIsTrue_shouldReturnTrue() {
        // The case `.risky` is only determined by `shouldNotifyRisky`
        
        let manager = UserManager.shared
        let validDate = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        let invalidDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        
        XCTAssertTrue(manager.shouldSendNotification(newStatus: .risky, shouldNotifyRisky: true, shouldNotifyEvenNoRisk: true, date: validDate))
        XCTAssertTrue(manager.shouldSendNotification(newStatus: .risky, shouldNotifyRisky: true, shouldNotifyEvenNoRisk: false, date: validDate))
        XCTAssertTrue(manager.shouldSendNotification(newStatus: .risky, shouldNotifyRisky: true, shouldNotifyEvenNoRisk: true, date: invalidDate))
        XCTAssertTrue(manager.shouldSendNotification(newStatus: .risky, shouldNotifyRisky: true, shouldNotifyEvenNoRisk: false, date: invalidDate))
    }
    
    func testShouldNotify_whenStatusChangeToRiskyAndShouldNotifyRiskyIsFalse_shouldReturnFalse() {
        // The case `.risky` is only determined by `shouldNotifyRisky`
        
        let manager = UserManager.shared
        let validDate = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        let invalidDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        
        XCTAssertFalse(manager.shouldSendNotification(newStatus: .risky, shouldNotifyRisky: false, shouldNotifyEvenNoRisk: true, date: validDate))
        XCTAssertFalse(manager.shouldSendNotification(newStatus: .risky, shouldNotifyRisky: false, shouldNotifyEvenNoRisk: false, date: validDate))
        XCTAssertFalse(manager.shouldSendNotification(newStatus: .risky, shouldNotifyRisky: false, shouldNotifyEvenNoRisk: true, date: invalidDate))
        XCTAssertFalse(manager.shouldSendNotification(newStatus: .risky, shouldNotifyRisky: false, shouldNotifyEvenNoRisk: false, date: invalidDate))
    }
    
    func testShouldNotify_whenStatusChangeToClearAndShouldNotifyEvenNoRiskIsEnabled_shouldDependsOnDateIsValidOrNot() {
        // The case `.clear` is determined by `shouldNotifyEvenNoRisk` and valid hour
        
        let manager = UserManager.shared
        let validDate = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        let invalidDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        
        XCTAssertTrue(manager.shouldSendNotification(newStatus: .clear, shouldNotifyRisky: true, shouldNotifyEvenNoRisk: true, date: validDate))
        XCTAssertTrue(manager.shouldSendNotification(newStatus: .clear, shouldNotifyRisky: false, shouldNotifyEvenNoRisk: true, date: validDate))
        XCTAssertFalse(manager.shouldSendNotification(newStatus: .clear, shouldNotifyRisky: true, shouldNotifyEvenNoRisk: true, date: invalidDate))
        XCTAssertFalse(manager.shouldSendNotification(newStatus: .clear, shouldNotifyRisky: false, shouldNotifyEvenNoRisk: true, date: invalidDate))
    }
    
    func testShouldNotify_whenStatusChangeToClearAndShouldNotifyEvenNoRiskIsDisabled_shouldAlwaysReturnFalse() {
        // The case `.clear` is determined by `shouldNotifyEvenNoRisk` and valid hour
        
        let manager = UserManager.shared
        let validDate = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
        let invalidDate = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        
        XCTAssertFalse(manager.shouldSendNotification(newStatus: .clear, shouldNotifyRisky: true, shouldNotifyEvenNoRisk: false, date: validDate))
        XCTAssertFalse(manager.shouldSendNotification(newStatus: .clear, shouldNotifyRisky: false, shouldNotifyEvenNoRisk: false, date: validDate))
        XCTAssertFalse(manager.shouldSendNotification(newStatus: .clear, shouldNotifyRisky: true, shouldNotifyEvenNoRisk: false, date: invalidDate))
        XCTAssertFalse(manager.shouldSendNotification(newStatus: .clear, shouldNotifyRisky: false, shouldNotifyEvenNoRisk: false, date: invalidDate))
    }
}
