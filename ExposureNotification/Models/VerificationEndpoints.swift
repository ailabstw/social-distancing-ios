//
//  VerificationEndpoints.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/3/25.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import Alamofire
import CoreKit
import ExposureNotification
import Foundation

enum VerificationEndpoint {
    case verify(code: String)
    case certificate(token: String, symmetricKey: SymmetricKey, exposureKeys: [ENTemporaryExposureKey])
    case verifyAcc(code: String)
    case getCode(phone: String)
}

extension VerificationEndpoint: URLRequestConvertible {
    private static let encoder = JSONEncoder()

    private var hostString: String {
        Config.hostString
    }

    private var apiKey: String {
        Config.apiKey
    }

    private var baseHeaders: HTTPHeaders {
        return [
            "content-type": "application/json",
            "accept": "application/json",
            "X-API-Key": apiKey
        ]
    }

    private var method: HTTPMethod {
        switch self {
        case .verify:
            return .post

        case .certificate:
            return .post

        case .verifyAcc:
            return .post
            
        case .getCode:
            return .post
        }
    }

    private var pathString: String {
        switch self {
        case .verify:
            return "/api/verify"

        case .certificate:
            return "/api/certificate"

        case .verifyAcc:
            return "/api/verify-acc"
        
        case .getCode:
            return "/api/phone-check"
        }
    }

    private var headers: HTTPHeaders {
        switch self {
        case .verify:
            return baseHeaders

        case .certificate:
            return baseHeaders

        case .verifyAcc:
            return baseHeaders
            
        case .getCode:
            return baseHeaders
        }
    }

    private var httpBody: Data? {
        switch self {
        case .verify(let code):
            return try? Self.encoder.encode(VerifyBody(code: code))

        case .certificate(let token, let symmetricKey, let exposureKeys):
            let message = exposureKeys.map { (key) in
                "\(key.keyData.base64EncodedString()).\(key.rollingStartNumber).\(key.rollingPeriod).\(key.transmissionRiskLevel)"
            }
            .sorted()
            .joined(separator: ",")

            let sha256MAC = message.hmac(using: .sha256, symmetricKey: symmetricKey)
            let ekeyhmac = sha256MAC.base64EncodedString()

            logger.debug("message: \(message)")
            logger.debug("symmetricKey: \(symmetricKey.withUnsafeBytes { Data($0).base64EncodedString() })")
            logger.debug("ekeyhmac: \(ekeyhmac)")

            return try? Self.encoder.encode(CertificateBody(token: token, ekeyhmac: ekeyhmac))

        case .verifyAcc(let code):
            return try? Self.encoder.encode(AlertCancellationBody(code: code))
            
        case .getCode(let phone):
            return try? Self.encoder.encode(RequestCodeBody(phone: phone))
        }
    }

    func asURLRequest() throws -> URLRequest {
        var request = try URLRequest(url: "\(hostString)\(pathString)", method: method, headers: headers)
        request.httpBody = httpBody

        return request
    }
}

extension VerificationEndpoint {
    enum TestType: String, Codable {
        case confirmed
        case likely
        case negative
    }

    struct VerifyBody: Encodable {
        let accept: [TestType] = [.confirmed, .likely, .negative]
        let code: String
    }

    struct VerifyResponse: Decodable {
        static let dateFormatter: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()

            formatter.formatOptions = [.withYear, .withMonth, .withDay, .withDashSeparatorInDate]

            return formatter
        }()

        let padding: String
        let testType: TestType
        let symptomDate: Date
        let testDate: Date
        let token: String

        private enum CodingKeys: String, CodingKey {
            case padding
            case testType = "testtype"
            case symptomDate
            case testDate
            case token
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            self.padding = try container.decode(String.self, forKey: .padding)
            self.testType = try container.decode(TestType.self, forKey: .testType)

            let symptomDateString = try container.decode(String.self, forKey: .symptomDate)

            guard let symptomDate = Self.dateFormatter.date(from: symptomDateString) else {
                throw DecodingError.dataCorruptedError(forKey: CodingKeys.symptomDate, in: container, debugDescription: "Expected date string to be ISO8601-formatted.")
            }
            self.symptomDate = symptomDate

            let testDateString = try container.decode(String.self, forKey: .testDate)

            guard let testDate = Self.dateFormatter.date(from: testDateString) else {
                throw DecodingError.dataCorruptedError(forKey: CodingKeys.testDate, in: container, debugDescription: "Expected date string to be ISO8601-formatted.")
            }
            self.testDate = testDate
            self.token = try container.decode(String.self, forKey: .token)
        }
    }

    struct CertificateBody: Encodable {
        let token: String
        let ekeyhmac: String
    }

    struct CertificateResponse: Decodable {
        let padding: String
        let certificate: String
    }

    struct AlertCancellationBody: Encodable {
        let code: String
    }

    struct AlertCancellationResponse: Decodable {
        let padding: String
    }
    
    struct RequestCodeBody: Encodable {
        let phone: String
    }
    
    struct RequestCodeResponse: Decodable {
        let checkResult: String?
        let errorCode: String?
        let error: String?
    }
}
