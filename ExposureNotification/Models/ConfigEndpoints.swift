//
//  ConfigEndpoints.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/20.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import Alamofire

enum ConfigEndpoint {
    case healthEducation(lang: LanguageCode)
    case config
}

extension ConfigEndpoint: URLRequestConvertible {
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
        case .healthEducation:
            return .get
        case .config:
            return .get
        }
    }

    private var pathString: String {
        switch self {
        case .healthEducation:
            return "/api/asset/health_education"
        case .config:
            return "/api/config"
        }
    }

    private var headers: HTTPHeaders {
        switch self {
        case .healthEducation:
            return baseHeaders
        case .config:
            return baseHeaders
        }
    }

    private var httpBody: Data? {
        switch self {
        case .healthEducation:
            return nil
        case .config:
            return nil
        }
    }
    
    private var parameters: Parameters? {
        switch self {
        case .healthEducation(let languageCode):
            return ["lang": languageCode.rawValue]
        case .config:
            return nil
        }
    }
    
    private var encoding: ParameterEncoding {
        return URLEncoding.default
    }

    func asURLRequest() throws -> URLRequest {
        var request = try URLRequest(url: "\(hostString)\(pathString)", method: method, headers: headers)
        request.httpBody = httpBody
        
        return try encoding.encode(request, with: parameters)
    }
}

extension ConfigEndpoint {
    enum LanguageCode: String {
        case zh = "zh-hant"
        case en
        case ms
        case my
        case `in`
        case vi
        case fil
        case th
        
        init(_ string: String) {
            switch string {
            case "zh-Hant":
                self = .zh
            case "ms-MY":
                self = .ms
            case "my-MM":
                self = .my
            case "id":
                self = .in
            case "vi":
                self = .vi
            case "tl":
                self = .fil
            case "th":
                self = .th
            default:
                self = .en
            }
        }
    }
}
