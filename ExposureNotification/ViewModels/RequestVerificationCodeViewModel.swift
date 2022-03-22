//
//  RequestVerificationCodeViewModel.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/2/23.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import CoreKit
import Foundation
import PromiseKit

class RequestVerificationCodeViewModel {
    enum SubmitResult {
        case succeed
        case failed
        case invalidPhoneFormat
        case requestLimitExceeded
        
        init(by result: VerificationCodeManager.RequestResult) {
            switch result {
            case .succeed:
                self = .succeed
            case .failed:
                self = .failed
            case .requestLimitExceeded:
                self = .requestLimitExceeded
            }
        }
    }
    
    private let phonePattern = "^09\\d{8}$"
    private let codeProvider = VerificationCodeManager()
    private lazy var phoneRegex: NSRegularExpression? = {
        return try? NSRegularExpression(pattern: phonePattern, options: [])
    }()
    
    func didTapSubmitButton(_ phone: String) -> Promise<SubmitResult> {
        guard phoneRegex?.matches(in: phone, range: NSRange(location: 0, length: phone.count)).count != 0 else {
            return .value(.invalidPhoneFormat)
        }
        return codeProvider.requestCode(by: phone)
            .map {
                SubmitResult(by: $0)
            }
    }
    
    func didTapClearButton() {
        codeProvider.clearCount()
    }
}
