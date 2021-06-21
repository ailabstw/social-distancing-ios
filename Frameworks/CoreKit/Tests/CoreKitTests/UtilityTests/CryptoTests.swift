//
//  CryptoTests.swift
//  CoreKit
//
//  Created by Shiva Huang on 2020/7/2.
//  Copyright © 2020 AILabs. All rights reserved.
//

#if canImport(CryptoKit)
import CryptoKit
import XCTest
@testable import CoreKit

@available(iOS 13.0, *)
final class CryptoTests: XCTestCase {
    func testSHA1() {
        let source = "AI Labs"
        let sourceData = source.data(using: .utf8)!
        let answer = Insecure.SHA1.hash(data: sourceData)
        
        XCTAssertTrue(answer.elementsEqual(source.hash(using: .sha1)))
        XCTAssertTrue(answer.elementsEqual(sourceData.hash(using: .sha1)))
    }
    
    func testSHA256() {
        let source = "AI Labs"
        let sourceData = source.data(using: .utf8)!
        let answer = SHA256.hash(data: sourceData)
        
        XCTAssertTrue(answer.elementsEqual(source.hash(using: .sha256)))
        XCTAssertTrue(answer.elementsEqual(sourceData.hash(using: .sha256)))
    }

    func testHMAC() {
        let message = "PzkinQIMJsLLRKoApG84aw==.2694960.144.1"
        let messageData = message.data(using: .utf8)!
        let symmetricKey = SymmetricKey(Data(base64Encoded: "So3/SHaxfvTJV5zZ//2RjQ==")!)
        let answer = HMAC<SHA256>.authenticationCode(for: messageData, using: CryptoKit.SymmetricKey(data: symmetricKey))

        XCTAssertTrue(answer.elementsEqual(message.hmac(using: .sha256, symmetricKey: symmetricKey)))
        XCTAssertTrue(answer.elementsEqual(messageData.hmac(using: .sha256, symmetricKey: symmetricKey)))
    }
    
    static var allTests = [
        ("testSHA1", testSHA1),
        ("testSHA256", testSHA256),
        ("testHMAC", testHMAC)
    ]
}
#endif
