//
//  DataExtensions.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/1.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation

extension Data {
    var bytes: [UInt8] {
        [UInt8](self)
    }
}
