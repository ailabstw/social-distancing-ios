//
//  WebViewModel.swift
//  CoreKit
//
//  Created by Shiva Huang on 2020/6/1.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import Foundation
import WebKit

open class WebViewController: UIViewController {
    
    private let viewModel: WebViewModel
    
    private(set) var isURLLoaded = false
    
    public lazy var webView: WKWebView = {
        $0.uiDelegate = self
        $0.navigationDelegate = self
        $0.scrollView.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        return $0
    }(WKWebView())

    public init(viewModel: WebViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available (*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        
        self.view.addSubview(webView)
        
        let constraints: [NSLayoutConstraint] = {
            if #available(iOS 11.0, *) {
                return [
                    webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    webView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
                    webView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
                    webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).layoutPriority(.medium)
                ]
            } else {
                return [
                    webView.topAnchor.constraint(equalTo: view.topAnchor),
                    webView.leftAnchor.constraint(equalTo: view.leftAnchor),
                    webView.rightAnchor.constraint(equalTo: view.rightAnchor),
                    webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).layoutPriority(.medium)
                ]
            }
        }()
        NSLayoutConstraint.activate(constraints)
        
        if let url = URL(string: viewModel.urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}

extension WebViewController: WKUIDelegate {
    public func webViewDidClose(_ webView: WKWebView) {
        viewModel.webViewDidClose()
    }
}

extension WebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel.webViewDidFinishLoading()
    }
}

extension WebViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            viewModel.webViewDidReachBottom()
        }
    }
}
