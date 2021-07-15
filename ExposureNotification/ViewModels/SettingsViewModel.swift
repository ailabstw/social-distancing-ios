//
//  SettingsViewModel.swift
//  COVID19
//
//  Created by Shiva Huang on 2020/5/26.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import CoreKit
import Foundation

class SettingsViewModel {
    @Observed(queue: .main)
    private(set) var title: String = Localizations.SettingsViewModel.title
    
    @Observed(queue: .main)
    private(set) var items: [TableViewCellViewModel] = []

    var exposureNotificationEngageHandler: TracingCellViewModel.EngageHandler? {
        set {
            tracingViewModel.engageHandler = newValue
        }
        get {
            tracingViewModel.engageHandler
        }
    }

    private let tracingViewModel = {
        TracingCellViewModel(title: Localizations.SettingsViewModel.Item.exposureNotification)
    }()
    
    init() {
        items.append(tracingViewModel)
    }
}

class TracingCellViewModel: TogglableCellViewModel {
    typealias EngageHandler = (ExposureManager.InactiveReason, @escaping (() -> Void)) -> Void

    private var observers: [NSObjectProtocol] = []

    var engageHandler: EngageHandler?

    init(title: String) {
        super.init(title: title, state: State(ExposureManager.shared.exposureNotificationStatus))

        observers = [
            ExposureManager.shared.$exposureNotificationStatus { [unowned self] in
                self.state = State(ExposureManager.shared.exposureNotificationStatus)
            }
        ]
    }
    
    deinit {
        observers.forEach {
            NotificationCenter.default.removeObserver($0)
        }
    }
    
    override func toggle() {
        switch ExposureManager.shared.exposureNotificationStatus {
        case .active:
            ExposureManager.shared.setExposureNotificationEnabled(false) { (error) in
                if let error = error  {
                    logger.error("\(error)")
                }
            }

        case .unknown, .inactive(.disabled):
            self.state = .processing

            ExposureManager.shared.setExposureNotificationEnabled(true) { (error) in
                if let error = error  {
                    logger.error("\(error)")
                }
            }

        case .inactive(let reason):
            self.state = .processing

            engageHandler?(reason, { [weak self] in
                self?.state = State(ExposureManager.shared.exposureNotificationStatus)
            })
        }
    }
}

private extension TracingCellViewModel.State {
    init(_ state: ExposureManager.Status) {
        switch state {
        case .active:
            self = .on
            
        case .unknown:
            self = .off
            
        case .inactive:
            self = .off
        }
    }
}

extension Localizations {
    enum SettingsViewModel {
        static let title = NSLocalizedString("DataControlView.Title",
                                             value: "Exposure Notification Settings",
                                             comment: "The title of settings view")

        enum Item {
            static let exposureNotification = NSLocalizedString("DataControlView.Item.ExposureNotification",
                                                                value: "Notification Service",
                                                                comment: "The title of item on data control view to enable/disable exposure notification")
        }
    }
}
