//
//  WebViewVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import WebKit

final class WebViewVC: UIViewController {
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()
    private var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.tintColor = .darkGray
        view.hidesWhenStopped = true
        return view
    }()
    
    private let rawUrl: String
    
    init(rawUrl: String) {
        self.rawUrl = rawUrl
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        loadUrl()
    }
    
    private func setupViews() {
        view.addSubview(webView)
        view.addSubview(activityIndicator)
        
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func loadUrl() {
        activityIndicator.startAnimating()
        guard let url = URL(string: rawUrl) else { return }
        webView.load(.init(url: url))
    }
}

extension WebViewVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
}
