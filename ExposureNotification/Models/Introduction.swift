//
//  Introduction.swift
//  Tracer
//
//  Created by Shiva Huang on 2020/4/1.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import Foundation
import UIKit

struct Introduction: Equatable {
    static func == (lhs: Introduction, rhs: Introduction) -> Bool {
        return
            lhs.title == rhs.title &&
            lhs.content == rhs.content &&
            lhs.figureName == rhs.figureName
    }
    
    let title: String
    let content: String
    let figureName: String
    let action: (title: String, block: () -> Void)?
}
