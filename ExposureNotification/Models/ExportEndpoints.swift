//
//  ExportEndpoints.swift
//  ExposureNotification
//
//  Created by Shiva Huang on 2021/3/30.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import Alamofire
import Foundation

enum ExportEndpoint {
    case index
    case download(path: String)
}

extension ExportEndpoint: URLRequestConvertible {
    private var hostString: String {
        Config.hostString
    }

    private var baseHeaders: HTTPHeaders {
        return [:]
    }

    private var method: HTTPMethod {
        switch self {
        case .index:
            return .get

        case .download:
            return .get
        }
    }

    private var pathString: String {
        switch self {
        case .index:
            return Config.indexPath

        case .download(let path):
            return "/\(path)"
        }
    }

    private var headers: HTTPHeaders {
        switch self {
        case .index:
            return baseHeaders

        case .download:
            return baseHeaders
        }
    }

    private var httpBody: Data? {
        switch self {
        case .index:
            return nil

        case .download:
            return nil
        }
    }

    func asURLRequest() throws -> URLRequest {
        var request = try URLRequest(url: "\(hostString)\(pathString)", method: method, headers: headers)
        request.httpBody = httpBody

        return request
    }
}
