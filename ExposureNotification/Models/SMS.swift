//
//  SMS.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/5/31.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import Foundation

struct SMS: Equatable {
    let recipient: String
    let body: String

    var url: URL {
        URL(string: "sms:\(recipient)&body=\(body)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
    }

    init?(_ stringValue: String) {
        guard stringValue.lowercased().hasPrefix("smsto:1922:") else {
            return nil
        }

        self.recipient = "1922"
        self.body = String(stringValue.dropFirst(11))
    }
}
