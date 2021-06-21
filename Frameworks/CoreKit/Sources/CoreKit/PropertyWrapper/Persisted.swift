//
//  Persisted.swift
//  CoreKit
//
//  Created by Shiva Huang on 2021/3/3.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import Foundation

/// Store any `Codable` value in `UserDefaults`, and post a notification when value changed.
///
/// To add handler for value changed notification, use
///
///     let observation = foo.$bar.addObserver { ... }
///
/// or just
///
///     let observation = foo.$bar { ... }
///
@propertyWrapper
public class Persisted<Value: Codable> {
    public init(userDefaultsKey: String, notificationName: Notification.Name, defaultValue: @autoclosure () -> Value) {
        self.userDefaultsKey = userDefaultsKey
        self.notificationName = notificationName
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                // WORKAROUND: https://forums.swift.org/t/allowing-top-level-fragments-in-jsondecoder/11750
                if #available(iOS 13, *) {
                    wrappedValue = try JSONDecoder().decode(Value.self, from: data)
                } else {
                    wrappedValue = try JSONDecoder().decode([Value].self, from: data).first ?? defaultValue()
                }
            } catch {
                wrappedValue = defaultValue()
            }
        } else {
            wrappedValue = defaultValue()
        }
    }

    public let userDefaultsKey: String
    public let notificationName: Notification.Name

    public var wrappedValue: Value {
        didSet {
            do {
                let valueToEncode: Data

                // WORKAROUND: https://forums.swift.org/t/allowing-top-level-fragments-in-jsondecoder/11750
                if #available(iOS 13, *) {
                    valueToEncode = try JSONEncoder().encode(wrappedValue)
                } else {
                    valueToEncode = try JSONEncoder().encode([wrappedValue])
                }

                UserDefaults.standard.set(valueToEncode, forKey: userDefaultsKey)
            } catch {

            }
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
    }

    public var projectedValue: Persisted<Value> { self }
    
    /// Adds an entry to the notification center to receive notifications that passed to the provided block.
    /// - Parameters:
    ///   - queue: The operation queue where the `block` runs. When `nil`, the block runs synchronously on the posting thread.
    ///   - block: The block that executes when receiving a notification.
    /// - Returns: An opaque object to act as the observer. Notification center strongly holds this return value until you remove the observer registration.
    public func addObserver(queue: OperationQueue? = nil, using block: @escaping () -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: notificationName, object: nil, queue: queue) { _ in
            block()
        }
    }

    /// A convenient method to invoke `addObserver(queue:using:)`.
    public func callAsFunction(queue: OperationQueue? = nil, using block: @escaping () -> Void) -> NSObjectProtocol {
        addObserver(queue: queue, using: block)
    }
}
