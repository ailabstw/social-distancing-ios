//
//  RiskSummary.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/4/13.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import ExposureNotification
import Foundation

struct RiskSummary {
    struct RiskSummaryItem: Codable {
        static let defaultBarValue: TimeInterval = 119
        fileprivate(set) var score: TimeInterval
        fileprivate(set) var bar: TimeInterval = Self.defaultBarValue

        var isRisky: Bool {
            score > bar
        }

        private enum CodingKeys: String, CodingKey {
            case score
            case bar
        }

        init(score: TimeInterval) {
            self.score = score
            self.bar = Self.defaultBarValue
        }

        init(score: TimeInterval, bar: TimeInterval) {
            self.score = score
            self.bar = max(bar, Self.defaultBarValue)
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.score = try container.decode(TimeInterval.self, forKey: .score)
            self.bar = max(try container.decode(TimeInterval.self, forKey: .bar), Self.defaultBarValue)
        }
    }

    private static let calendar: Calendar = {
        var cal = Calendar.current

        cal.timeZone = TimeZone(secondsFromGMT: 0)!

        return cal
    }()

    private var store: [ENIntervalNumber: RiskSummaryItem] = [:]

    private var pruneIntervalNumber: ENIntervalNumber {
        Calendar.current.date(byAdding: .day, value: -15, to: Calendar.current.startOfDay(for: Date()))!.enIntervalNumber
    }
    
    var startNumber: ENIntervalNumber {
        let alarmPeriod = ServerConfigManager.shared.alarmPeriod
        return Calendar.current.date(byAdding: .day, value: -alarmPeriod, to: Calendar.current.startOfDay(for: Date()))!.enIntervalNumber
    }

    var isRisky: Bool {
        store.first { (key, value) -> Bool in
            key >= startNumber && value.isRisky
        } != nil
    }

    mutating func updateRiskSummary(_ summary: ENExposureDetectionSummary?) {
        var _store = store

        summary?.daySummaries.forEach { (daySummary) in
            let storeKey = daySummary.date.enIntervalNumber
            _store[storeKey] = RiskSummaryItem(score: daySummary.daySummary.weightedDurationSum,
                                               bar: _store[storeKey]?.bar ?? RiskSummaryItem.defaultBarValue)
        }

        store = _store.prune(startNumber: pruneIntervalNumber)
    }

    mutating func updateBar(before rollingNumber: ENIntervalNumber) {
        store = Dictionary(uniqueKeysWithValues: store.map {
            if $0.key > rollingNumber {
                return $0
            } else {
                var item = $0
                item.value.bar = item.value.score

                return item
            }
        })
        .prune(startNumber: pruneIntervalNumber)
    }

    subscript(date: Date) -> RiskSummaryItem {
        let startNumber = Self.calendar.startOfDay(for: date).enIntervalNumber

        return store[startNumber] ?? RiskSummaryItem(score: 0)
    }
}

extension RiskSummary: Codable {
    private enum CodingKeys: String, CodingKey {
        case store
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.store = try container.decode([ENIntervalNumber: RiskSummaryItem].self, forKey: .store).prune(startNumber: pruneIntervalNumber)
    }
}

extension RiskSummary: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (ENIntervalNumber, RiskSummaryItem)...) {
        self.store = Dictionary(uniqueKeysWithValues: elements).prune(startNumber: pruneIntervalNumber)
    }
}

private extension Dictionary where Key == ENIntervalNumber, Value == RiskSummary.RiskSummaryItem {
    func prune(startNumber: ENIntervalNumber) -> Self {
        self.filter {
            $0.key >= startNumber
        }
    }
}
