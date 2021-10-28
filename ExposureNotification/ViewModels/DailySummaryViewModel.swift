//
//  DailySummaryViewModel.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/6/1.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import CoreKit
import Foundation

class DailySummaryViewModel {
    private static let utcCalendar: Calendar = {
        var cal = Calendar.current

        cal.timeZone = TimeZone(secondsFromGMT: 0)!

        return cal
    }()

    @Observed(queue: .main)
    private(set) var title: String = Localizations.DailySummaryViewModel.title

    @Observed(queue: .main)
    private(set) var daySummaries: [DaySummaryCellViewModel] = []

    @Observed(queue: .main)
    private(set) var updateTimeString: String = ""

    private var updateTime: Date = ExposureManager.shared.dateLastPerformedExposureDetection {
        didSet {
            updateLastCheckTime()
        }
    }

    private var observers: [NSObjectProtocol] = []

    init() {
        observers = [
            UserManager.shared.$riskSummary { [unowned self] in
                updateDaySummaries()
            },
            ExposureManager.shared.$dateLastPerformedExposureDetection { [unowned self] in
                self.updateTime = ExposureManager.shared.dateLastPerformedExposureDetection
            }
        ]

        updateDaySummaries()
        updateLastCheckTime()
    }

    deinit {
        observers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }

    private func updateDaySummaries() {
        let today = Self.utcCalendar.startOfDay(for: Date())
        let riskSummary = UserManager.shared.riskSummary

        daySummaries = (0...14).map {
            Self.utcCalendar.date(byAdding: .day, value: -$0, to: today)!
        }
        .map {
            DaySummaryCellViewModel(date: $0, summary: riskSummary[$0])
        }

    }

    private func updateLastCheckTime() {
        updateTimeString = Localizations.DailySummaryViewModel.updateTime(date: updateTime)
    }
}

extension DailySummaryViewModel: CustomStringConvertible {
    var description: String {
        "DailySummaryViewModel(updateTime: \(updateTime), daySummaries: \(daySummaries))"
    }
}

class DaySummaryCellViewModel {
    private static let dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .medium

        return formatter
    }()

    private let date: Date
    private let score: TimeInterval
    let isRisky: Bool

    var dateString: String {
        Self.dateFormatter.string(from: date)
    }

    var exposureDurationString: String {
        switch score {
        case 0:
            return Localizations.DaySummaryCellViewModel.ExposureDuration.noContact

        case 0..<120:
            return Localizations.DaySummaryCellViewModel.ExposureDuration.lessThan2Mins

        case 120...:
            return Localizations.DaySummaryCellViewModel.ExposureDuration.moreThan2Mins(duration: score)

        default:
            return ""
        }
    }

    init(date: Date, summary: RiskSummary.RiskSummaryItem) {
        self.date = date
        self.isRisky = summary.isRisky
        self.score = summary.score
    }
}

extension DaySummaryCellViewModel: CustomStringConvertible {
    var description: String {
        "DaySummaryCellViewModel(date: \(date), score: \(score), isRisky: \(isRisky))"
    }
}

extension Localizations {
    enum DailySummaryViewModel {
        private static let dateFormatter: DateFormatter = {
            var formatter = DateFormatter()

            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            formatter.setLocalizedDateFormatFromTemplate("MMM d yyyy jj:mm")

            return formatter
        }()

        static let title = NSLocalizedString("DailySummaryViewModel.Title",
                                             value: "Daily Summary",
                                             comment: "The title of daily summary view")
        static func updateTime(date: Date) -> String {
            guard date != .distantPast else {
                return ""
            }

            return String(format: NSLocalizedString("DailySummaryViewModel.LastCheckTimeLabel",
                                                    value: "Last checked at %@",
                                                    comment: "The label text on daily summary view to indicate the last time checking exposures"),
                          DailySummaryViewModel.dateFormatter.string(from: date))
        }
    }

    enum DaySummaryCellViewModel {
        enum ExposureDuration {
            private static let dateComponentsFormatter: DateComponentsFormatter = {
                var formatter = DateComponentsFormatter()

                formatter.unitsStyle = .brief
                formatter.allowedUnits = [.hour, .minute]

                return formatter
            }()

            static let noContact = NSLocalizedString("DaySummaryCellViewModel.ExposureDuration.NoContact",
                                                     value: "No contact",
                                                     comment: "The message on Daily Summary view for no contact")
            static let lessThan2Mins = NSLocalizedString("DaySummaryCellViewModel.ExposureDuration.lessThan2Mins",
                                                         value: "Less than 2 mins",
                                                         comment: "The message on Daily Summary view for contact less than 2 minutes")
            static func moreThan2Mins(duration: TimeInterval) -> String {
                String(format: NSLocalizedString("DaySummaryCellViewModel.ExposureDuration.moreThan2Mins",
                                                 value: "%@",
                                                 comment: "The message on Daily Summary view for contact more than 2 minutes"),
                       Self.dateComponentsFormatter.string(from: duration)!)
            }
        }
    }
}
