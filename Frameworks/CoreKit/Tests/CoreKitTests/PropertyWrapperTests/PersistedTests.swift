//
//  PersistedTests.swift
//  CoreKit
//
//  Created by Shiva Huang on 2021/4/15.
//  Copyright © 2021 AILabs. All rights reserved.
//

import XCTest
@testable import CoreKit

final class PersistedTests: XCTestCase {
    private struct Foo {
        static var defaultBar: Int {
            XCTAssertNil(UserDefaults.standard.object(forKey: "bar"))
            return 0
        }

        @Persisted(userDefaultsKey: "bar", notificationName: Notification.Name("Foo.barDidChange"), defaultValue: Foo.defaultBar)
        var bar: Int
    }

    private struct Box<Value: Codable>: Codable {
        let value: Value

        init(_ value: Value) {
            self.value = value
        }
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "bar")
    }

    func testPersistedObservation() {
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 1

        let foo = Foo()

        let observation = foo.$bar { () in
            XCTAssertEqual(foo.bar, 1)
            expectation.fulfill()
        }

        foo.bar = 1

        wait(for: [expectation], timeout: 3.0)

        NotificationCenter.default.removeObserver(observation)
    }

    func testPersistedDefaultValue() {
        UserDefaults.standard.setValue(try! JSONEncoder().encode(Box(1)), forKey: "bar")

        let foo = Foo()

        XCTAssertEqual(foo.bar, 1)
    }

    func testPersistedLazyDefaultValue() {
        let foo = Foo()

        XCTAssertEqual(foo.bar, 0)
    }
    
    static var allTests = [
        ("testPersistedObservation", testPersistedObservation),
        ("testPersistedDefaultValue", testPersistedDefaultValue),
        ("testPersistedLazyDefaultValue", testPersistedLazyDefaultValue)
    ]
}
