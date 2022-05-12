//
//  AssetEndpoints.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/4/20.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import Alamofire

enum AssetEndpoint {
    case healthEducation(lang: LanguageCode)
}

extension AssetEndpoint: URLRequestConvertible {
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
        }
    }

    private var pathString: String {
        switch self {
        case .healthEducation:
            return "/api/asset/health_education"
        }
    }

    private var headers: HTTPHeaders {
        switch self {
        case .healthEducation:
            return baseHeaders
        }
    }

    private var httpBody: Data? {
        switch self {
        case .healthEducation:
            return nil
        }
    }
    
    private var parameters: Parameters? {
        switch self {
        case .healthEducation(let languageCode):
            return ["lang": languageCode.rawValue]
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

extension AssetEndpoint {
    enum LanguageCode: String {
        case zh = "zh-hant"
        case en
        
        init(_ string: String) {
            switch string {
            case "zh-Hant":
                self = .zh
            default:
                self = .en
            }
        }
    }
}
