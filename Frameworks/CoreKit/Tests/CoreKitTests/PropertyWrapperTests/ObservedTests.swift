//
//  ObservedTests.swift
//  CoreKit
//
//  Created by Shiva Huang on 2020/5/29.
//  Copyright © 2020 AILabs. All rights reserved.
//

import XCTest
@testable import CoreKit

final class ObservedTests: XCTestCase {
    private struct Foo {
        @Observed
        var bar: Int = 0

        @Observed
        private(set) var value: Int = 0

        func update(_ newValue: Int) {
            value = newValue
        }
    }
    
    func testInitializer() {
        let expectation = XCTestExpectation()
        
        let foo = Foo()
        foo.$bar { (value) in
            XCTAssertEqual(value, 0)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testPublicObserver() {
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        
        let foo = Foo()
        foo.$bar { (value) in
            expectation.fulfill()
        }
        
        foo.bar = 1
        
        wait(for: [expectation], timeout: 3.0)
    }

    func testPrivateSetObserver() {
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2

        let foo = Foo()
        foo.$value { (value) in
            expectation.fulfill()
        }

        foo.update(1)

        wait(for: [expectation], timeout: 3.0)
    }

    func testObserverCancellation() {
        let expectation = XCTestExpectation()
        expectation.assertForOverFulfill = true

        let foo = Foo()
        foo.$bar { (value) in
            XCTAssertEqual(value, 0)

            expectation.fulfill()
        }

        foo.$bar.cancel()

        wait(for: [expectation], timeout: 3.0)
    }

    static var allTests = [
        ("testInitializer", testInitializer),
        ("testPublicObserver", testPublicObserver),
        ("testPrivateSetObserver", testPrivateSetObserver),
        ("testObserverCancellation", testObserverCancellation)
    ]
}
