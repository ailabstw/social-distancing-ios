//
//  NSLayoutConstraintExtensions.swift
//  CoreKit
//
//  Created by Shiva Huang on 2020/8/12.
//  Copyright © 2020 AILabs. All rights reserved.
//
#if canImport(UIKit)
import UIKit

public extension NSLayoutConstraint {
    // Ref: https://www.avanderlee.com/swift/auto-layout-programmatically/
    /// Sets the priority by which a parent layout should apportion space to the child.
    ///
    /// - Parameter priority: The priority to be set.
    /// - Returns: The constraint adjusted with the new priority.
    func layoutPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
    
}
#endif
