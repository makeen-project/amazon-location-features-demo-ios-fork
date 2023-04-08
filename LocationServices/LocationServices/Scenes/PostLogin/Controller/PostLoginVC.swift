//
//  PostLoginVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class PostLoginVC: UIViewController {
 
    var dismissHandler: VoidHandler?
    

    var viewModel: PostLoginViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private var postLoginView: PostLoginView = PostLoginView()
    override func viewDidLoad() {
        super.viewDidLoad()
        postLoginView.delegate = self
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        self.view.addSubview(postLoginView)
        postLoginView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension PostLoginVC: PostLoginViewOutputDelegate {
    func dismissAction() {
        self.dismissHandler?()
    }
    
    func signInAction() {
        viewModel.login()
    }
}

extension PostLoginVC: PostLoginViewModelOutputDelegate {
    func sigInCompleted() {
        self.dismissHandler?()
    }
}
