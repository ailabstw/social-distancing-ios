//
//  DateExtensions.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/3/3.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import ExposureNotification
import Foundation

extension Date {
    private static let displayDateTimeFormatter: DateFormatter = {
        $0.dateFormat = "yyyy/MM/dd HH:mm"
        $0.locale = Locale(identifier: "zh_TW")

        return $0
    }(DateFormatter())

    private static let displayDateFormatter: DateFormatter = {
        $0.dateFormat = "yyyy/MM/dd"
        $0.locale = Locale(identifier: "zh_TW")

        return $0
    }(DateFormatter())

    func toDateTimeString(dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_TW")
        formatter.dateFormat = dateFormat
        let result = formatter.string(from: self)
        return result
    }

    var displayDateTimeDescription: String {
        Self.displayDateTimeFormatter.string(from: self)
    }

    var displayDateDescription: String {
        Self.displayDateFormatter.string(from: self)
    }

    var remainingDays: Int {
        days(from: Date(), to: self)
    }

    var enIntervalNumber: ENIntervalNumber {
        ENIntervalNumber(self.timeIntervalSince1970 / (60 * 10))
    }

    func days(from start: Date, to end: Date) -> Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: start), to: Calendar.current.startOfDay(for: end)).day!
    }

    func isSameDay(to date:Date) -> Bool {
        days(from: self, to: date) == 0
    }
}
