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

    var displayDateTimeDescription: String {
        Self.displayDateTimeFormatter.string(from: self)
    }

    var displayDateDescription: String {
        Self.displayDateFormatter.string(from: self)
    }

    var enIntervalNumber: ENIntervalNumber {
        ENIntervalNumber(self.timeIntervalSince1970 / (60 * 10))
    }
}
