//
//  ResetPasswordVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class ResetPasswordVC: UIViewController {
    private var resetPasswordView = ResetPasswordView()
    var viewModel: ResetPasswordViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .mapDarkBlackColor
        self.navigationItem.title = "Reset Password"
        self.view.backgroundColor = .white
        
        self.view.addSubview(resetPasswordView)
        resetPasswordView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(24)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}

