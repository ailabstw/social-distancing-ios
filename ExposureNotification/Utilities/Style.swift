//
//  Style.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/23.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import UIKit
import Foundation

extension UIFont {
    convenience init?(size: CGFloat, weight: Weight) {
        let name: String = {
            switch weight {
            case .bold:
                return "PingFang-TC-Bold"
            case .semibold:
                return "PingFang-TC-Semibold"
            case .medium:
                return "PingFang-TC-Medium"
            case .light:
                return "PingFang-TC-Light"
            case .thin:
                return "PingFang-TC-Thin"
            default:
                return "PingFang-TC-Regular"
            }
        }()
        
        self.init(name: name, size: size)
    }
}
