//
//  UILayoutPriorityExtensions.swift
//  CoreKit
//
//  Created by Shiva Huang on 2020/8/12.
//  Copyright © 2020 AILabs. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public extension UILayoutPriority {
    // Ref: https://github.com/SnapKit/SnapKit/blob/develop/Source/ConstraintPriority.swift
    static var medium: UILayoutPriority {
        #if os(OSX)
            return UILayoutPriority(501.0)
        #else
            return UILayoutPriority(500.0)
        #endif
        
    }
}
#endif
