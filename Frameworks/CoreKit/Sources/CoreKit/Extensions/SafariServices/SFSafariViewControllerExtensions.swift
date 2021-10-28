//
//  SFSafariViewControllerExtensions.swift
//  ExposureNotification
//
//  Created by Chuck on 2021/6/2.
//  Copyright © 2021 AI Labs. All rights reserved.
//

import SafariServices

public extension SFSafariViewController {
    convenience init(viewModel: WebViewModel) {
        let (configuration, dismissButtonStyle): (Configuration, DismissButtonStyle) = {
            if let safariViewModel = viewModel as? SafariViewModel {
                return (safariViewModel.configuration, safariViewModel.dismissButtonStyle)
            } else {
                return (Configuration(), .close)
            }
        }()

        self.init(url: URL(string: viewModel.urlString)!, configuration: configuration)
        self.dismissButtonStyle = dismissButtonStyle
    }
}
