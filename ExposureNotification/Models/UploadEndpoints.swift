//
//  UploadEndpoints.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/3/29.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import Alamofire
import CoreKit
import ExposureNotification
import Foundation

enum UploadEndpoint {
    case publish(symmetricKey: SymmetricKey, exposureKeys: [ENTemporaryExposureKey], certificate: String, symptomDate: Date, isTraveler: Bool = false)
}

extension UploadEndpoint: URLRequestConvertible {
    private static let encoder = JSONEncoder()

    private var hostString: String {
        Config.hostString
    }

    private var baseHeaders: HTTPHeaders {
        return [
            "content-type": "application/json",
            "accept": "application/json"
        ]
    }

    private var method: HTTPMethod {
        switch self {
        case .publish:
            return .post
        }
    }

    private var pathString: String {
        switch self {
        case .publish:
            return "/v1/publish"
        }
    }

    private var headers: HTTPHeaders {
        switch self {
        case .publish:
            return baseHeaders
        }
    }

    private var httpBody: Data? {
        switch self {
        case .publish(let symmetricKey, let exposureKeys, let certificate, let symptomDate, let isTraveler):
            return try? Self.encoder.encode(PublishBody(temporaryExposureKeys: exposureKeys,
                                                        healthAuthorityID: Config.healthAuthorityID,
                                                        hmacKey: {
                                                            symmetricKey.withUnsafeBytes {
                                                                Data($0).base64EncodedString()
                                                            }
                                                        }(),
                                                        verificationPayload: certificate,
                                                        traveler: isTraveler,
                                                        symptomOnsetInterval: symptomDate.enIntervalNumber,
                                                        revisionToken: ExposureManager.shared.revisionToken))
        }
    }

    func asURLRequest() throws -> URLRequest {
        var request = try URLRequest(url: "\(hostString)\(pathString)", method: method, headers: headers)
        request.httpBody = httpBody

        return request
    }
}

extension UploadEndpoint {
    struct PublishBody: Encodable {
        let temporaryExposureKeys: [ENTemporaryExposureKey]
        let healthAuthorityID: String
        let hmacKey: String
        let verificationPayload: String
        let traveler: Bool
        let symptomOnsetInterval: ENIntervalNumber
        let revisionToken: String?
    }

    struct PublishResponse: Decodable {
        let revisionToken: String?
        let insertedExposures: Int?
        let padding: String
    }
}
