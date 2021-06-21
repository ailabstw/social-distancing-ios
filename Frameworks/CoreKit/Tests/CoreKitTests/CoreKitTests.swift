import XCTest
@testable import CoreKit

final class CoreKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CoreKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
