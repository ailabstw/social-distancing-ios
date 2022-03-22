//
//  VerificationCodeManager.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/2/23.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import CoreKit
import Foundation
import PromiseKit

class VerificationCodeManager {
    static let verificationRequestedInfoKey = "verificationRequestedInfo"
    
    struct VerificationRequestedInfo: Codable {
        let requestHistory: [Date]
    }
    
    enum RequestResult {
        case succeed
        case failed
        case requestLimitExceeded
    }
    
    private let apiManager = APIManager.shared
    private let requestLimit = 3
    
    @Persisted(userDefaultsKey: VerificationCodeManager.verificationRequestedInfoKey, notificationName: requestVerificationInfoNotification, defaultValue: nil)
    private var requestInfo: VerificationRequestedInfo?
    
    func requestCode(by phone: String) -> Promise<RequestResult> {
        if let info = requestInfo, info.requestHistory.count > requestLimit, info.requestHistory[info.requestHistory.count - 2].isSameDay(to: Date()) {
            return .value(.requestLimitExceeded)
        }
        
        return APIManager.shared.request(VerificationEndpoint.getCode(phone: phone))
            .map { [weak self] (response: VerificationEndpoint.RequestCodeResponse) in
                if let errorCode = response.errorCode {
                    logger.error("Request Code Failed, error code: \(errorCode)")
                    return .failed
                }
                if let checkResult = response.checkResult {
                    logger.info("Request Code Succeed, result: \(checkResult)")
                    var currentHistory = self?.requestInfo?.requestHistory ?? []
                    currentHistory.append(Date())
                    self?.requestInfo = VerificationRequestedInfo(requestHistory: currentHistory)
                    return .succeed
                } else {
                    return .failed
                }
        }
    }
    
    func clearCount() {
        requestInfo = nil
    }
}

extension VerificationCodeManager {
    static let requestVerificationInfoNotification = Notification.Name("VerificationCodeProvider.verificationRequestedInfo")
}
