//
//  Observed.swift
//  CoreKit
//
//  Created by Shiva Huang on 2020/3/23.
//  Copyright © 2020 AILabs. All rights reserved.
//

import Foundation

@propertyWrapper
public class Observed<T> {
    private var _value: T {
        didSet {
            execute()
        }
    }
    
    private var _closure: ((T) -> Void)? {
        didSet {
            execute()
        }
    }
    
    private var _queue: DispatchQueue? = nil
    
    public var wrappedValue: T {
        get {
            _value
        }
        set {
            _value = newValue
        }
    }

    public var projectedValue: Observed<T> {
        self
    }
    
    public init(wrappedValue: T, queue: DispatchQueue? = nil) {
        self._value = wrappedValue
        self._queue = queue
    }

    public func observe(using block: @escaping (T) -> Void) {
        _closure = block
    }

    public func callAsFunction(using block: @escaping (T) -> Void) {
        observe(using: block)
    }

    public func cancel() {
        _closure = nil
    }
    
    private func execute() {
        guard let closure = _closure else {
            return
        }
        
        let value = _value
        
        // If target queue is .main and currently running on main thread, no need to execute async.
        // | Queue    | Thread   | Operation |
        // | -------- | -------- | --------- |
        // | nil      | main     | sync      |
        // | nil      | not main | sync      |
        // | main     | main     | sync      |
        // | main     | not main | async     |
        // | not main | main     | async     |
        // | not main | not main | async     |
        
        if let queue = _queue, (queue != DispatchQueue.main || Thread.isMainThread == false) {
            queue.async {
                closure(value)
            }
        } else {
            closure(value)
        }
    }
}
