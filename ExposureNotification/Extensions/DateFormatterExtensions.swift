//
//  DateFormatterExtensions.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/1.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let dayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
