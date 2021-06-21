//
//  Notified.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/3/17.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import Foundation

@propertyWrapper
class Notified<Value: Equatable> {
    let notificationName: Notification.Name

    var wrappedValue: Value {
        didSet {
            if oldValue != wrappedValue {
                NotificationCenter.default.post(name: notificationName, object: nil)
            }
        }
    }
    
    var projectedValue: Notified<Value> { self }

    init(wrappedValue: Value, notificationName: Notification.Name) {
        self.wrappedValue = wrappedValue
        self.notificationName = notificationName
    }
    
    func callAsFunction(using block: @escaping () -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil) { _ in
            block()
        }
    }
}
