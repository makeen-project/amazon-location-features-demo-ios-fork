//
//  LoginFooterView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class LoginFooterView: UIView {
    
    private var containerView: UIView = UIView()

    private var footerText: UILabel = {
        let label = UILabel()
        label.text = "By connecting I agree to Amazon Location’s"
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var footerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Terms & Conditions", for: .normal)
        button.setTitleColor(.lsPrimary, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .amazonFont(type: .bold, size: 13)
        button.addTarget(self, action: #selector(footerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(footerText)
        containerView.addSubview(footerButton)
        
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(36)
            $0.trailing.equalToSuperview().offset(-36)
        }
        
        footerText.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        footerButton.snp.makeConstraints {
            $0.top.equalTo(footerText.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(16)
        }
        
    }
    
    @objc func footerButtonTapped() {
        guard let url = URL(string: StringConstant.termsAndConditionsURL) else { return }
        UIApplication.shared.open(url)
    }
}
