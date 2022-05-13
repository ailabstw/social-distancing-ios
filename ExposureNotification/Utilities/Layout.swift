//
//  Layout.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/5/12.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit

struct Layout {
    static let screenHeight: CGFloat = UIScreen.main.bounds.height
    static let maxHeight: CGFloat = 926
    
    static func calculate(_ value: CGFloat) -> CGFloat {
        return screenHeight / maxHeight * value
    }
}
