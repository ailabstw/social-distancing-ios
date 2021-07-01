//
//  Notified.swift
//  CoreKit
//
//  Created by Shiva Huang on 2021/3/17.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import Foundation

@propertyWrapper
public class Notified<Value: Equatable> {
    public let notificationName: Notification.Name

    public var wrappedValue: Value {
        didSet {
            if oldValue != wrappedValue {
                NotificationCenter.default.post(name: notificationName, object: nil)
            }
        }
    }
    
    public var projectedValue: Notified<Value> { self }

    public init(wrappedValue: Value, notificationName: Notification.Name) {
        self.wrappedValue = wrappedValue
        self.notificationName = notificationName
    }
    
    public func callAsFunction(using block: @escaping () -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: nil) { _ in
            block()
        }
    }
}
