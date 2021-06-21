//
//  APIManager.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/3/25.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import Alamofire
import Foundation
import PMKAlamofire
import PromiseKit

class APIManager {
    private static let decoder = JSONDecoder()

    static let shared = APIManager()

    private let validator: DataRequest.Validation = { (request, response, data) -> Request.ValidationResult in
            guard (200...299).contains(response.statusCode) else {
                let message: APIError.Message? = {
                    if let data = data {
                        return try? APIManager.decoder.decode(APIError.Message.self, from: data)
                    }

                    return nil
                }()

                return .failure(APIError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode),
                                                                  message: message))
            }

            return .success
    }

    func request<T: Decodable>(_ endpoint: URLRequestConvertible) -> Promise<T> {
        Alamofire.request(endpoint)
            .validate(validator)
            .validate()
            .responseDecodable(T.self, decoder: Self.decoder)
    }

    func request(_ endpoint: URLRequestConvertible) -> Promise<String> {
        Alamofire.request(endpoint)
            .validate(validator)
            .validate()
            .responseString()
            .map {
                $0.string
            }
    }

    func download(_ endpoint: URLRequestConvertible, to destination: DownloadRequest.DownloadFileDestination?) -> Promise<URL> {
        Alamofire.download(endpoint, to: destination)
            .validate()
            .response(.promise)
            .compactMap {
                $0.destinationURL ?? $0.temporaryURL
            }
    }

    enum APIError: Error {
        struct Message: Error, Decodable {
            let error: String
            let code: String

            private enum CodingKeys: String, CodingKey {
                case error
                case errorCode
                case code
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)

                self.error = try container.decode(String.self, forKey: .error)
                self.code = try container.decodeIfPresent(String.self, forKey: .errorCode) ?? container.decode(String.self, forKey: .code)
            }
        }

        case responseValidationFailed(reason: AFError.ResponseValidationFailureReason, message: Message? = nil)
    }
}
