//
//  WebViewModel.swift
//  CoreKit
//
//  Created by Shiva Huang on 2020/6/1.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import Foundation

open class WebViewModel {
    public let title: String?
    public let urlString: String
    public internal(set) var isURLLoaded = false
    
    public init(title: String, urlString: String) {
        self.title = title
        self.urlString = urlString
    }
    
    open func webViewDidFinishLoading() {
        isURLLoaded = true
    }
    
    open func webViewDidClose() { }
    
    open func webViewDidReachBottom() { }
}

open class AgreementWebViewModel: WebViewModel {
    @Observed
    public var isReviewed: Bool = false
    
    private var agreementDidAccept: (() -> Void)?
    
    public required init(title: String, urlString: String, agreementAccepted: (() -> Void)? = nil) {
        self.agreementDidAccept = agreementAccepted
        
        super.init(title: title, urlString: urlString)
    }
    
    public override func webViewDidReachBottom() {
        if isURLLoaded {
            isReviewed = true
        }
    }
    
    open func acceptAgreement() {
        agreementDidAccept?()
    }
}
