//
//  SpinnerShowable.swift
//  ExposureNotification
//
//  Created by Chuck on 2022/3/8.
//  Copyright © 2022 AI Labs. All rights reserved.
//

import Foundation
import UIKit

struct AssociatedKeys {}

protocol SpinnerShowable where Self: UIViewController {
    func startSpinner()
    func stopSpinner()
}

extension AssociatedKeys {
    static var spinner: UInt8 = 0
}

extension SpinnerShowable {
    private var spinner: UIActivityIndicatorView? {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.spinner) as? UIActivityIndicatorView else { return nil }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.spinner, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func startSpinner() {
        if spinner == nil {
            spinner = createSpinner()
        }
        
        spinner?.startAnimating()
    }
    
    func stopSpinner() {
        guard let spinner = spinner else { return }
        spinner.stopAnimating()
    }
    
    private func createSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView()
        spinner.style = {
            if #available(iOS 13.0, *) {
                return .large
            } else {
                return .whiteLarge
            }
        }()
        
        view.addSubview(spinner)
        spinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return spinner
    }
    
}
