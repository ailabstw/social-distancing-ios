//
//  LoggingSwiftyBeaverTests.swift
//  swift-log-SwiftyBeaver
//
//  Created by Shiva Huang on 2020/6/8.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import XCTest
@testable import LoggingSwiftyBeaver
import Logging
import SwiftyBeaver

final class LoggingSwiftyBeaverTests: XCTestCase {
    func testExample() {
        let logger = Logger(label: "SwiftyBeaver", factory: { (label) in
            SwiftyBeaver.LogHandler(label, destinations: [ConsoleDestination()])
        })
        
        
        logger.info("Info from SwiftyBeaver", metadata: ["nested": ["fave-numbers": ["\(1)", "\(2)", "\(3)"], "foo": "bar"]])
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
