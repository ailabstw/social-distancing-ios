//
//  WebViewController.swift
//  COVID19 Quarantine
//
//  Created by Shiva Huang on 2020/4/22.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import CoreKit
import SnapKit
import UIKit
import WebKit

class WebViewController: UIViewController {
    
    private let viewModel: WebViewModel
    
    private(set) var isURLLoaded = false
    
    fileprivate lazy var webView: WKWebView = {
        let view = WKWebView()

        view.uiDelegate = self
        view.navigationDelegate = self
        view.scrollView.delegate = self
        
        return view
    }()

    init(viewModel: WebViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        
        self.view.backgroundColor = Color.background
        self.view.addSubview(webView)
        
        webView.snp.makeConstraints {
            $0.top.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).priority(.medium)
        }
        
        if let url = URL(string: viewModel.urlString) {
            webView.load(URLRequest(url: url))
        }
    }

}

extension WebViewController: WKUIDelegate {
    func webViewDidClose(_ webView: WKWebView) {
        viewModel.webViewDidClose()
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isURLLoaded = true
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }
    
}

extension WebViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isURLLoaded {
            if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
                viewModel.webViewDidReachBottom()
            }
        }
    }
}

extension WebViewController {
    enum Color {
        static let background = UIColor(red: (235/255.0), green: (235/255.0), blue: (235/255.0), alpha: 1)
    }
}

class PrivacyWebViewController: WebViewController {
    private let viewModel: PrivacyWebViewModel
    
    private lazy var acceptButton: StyledButton = {
        let button = StyledButton(style: .major)

        button.setTitle("同意並繼續", for: .normal)
        
        button.addTarget(self, action: #selector(didTapAcceptButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    init(viewModel: PrivacyWebViewModel) {
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let console: UIView = {
            let _view = UIView()
            
            _view.backgroundColor = Color.background
            _view.addSubview(acceptButton)
            
            acceptButton.snp.makeConstraints {
                $0.width.equalTo(240)
                $0.height.equalTo(48)
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview().offset(18)
            }
            
            return _view
        }()
        
        view.addSubview(console)
        
        console.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-83)
        }
        
        webView.snp.makeConstraints {
            $0.bottom.equalTo(console.snp.top).priority(.required)
        }
        
        viewModel.$reviewed { [weak self] (reviewed) in
            self?.acceptButton.isEnabled = reviewed
        }
    }
    
    @objc private func didTapAcceptButton(_ sender: UIButton) {
        viewModel.acceptPrivacy()
    }
}
