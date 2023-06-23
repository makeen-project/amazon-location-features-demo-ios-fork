//
//  LoginCloseAppAlertView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class LoginCloseAppAlertView: UIView {
    
    private var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .alertTriangleSolid
        imageView.tintColor = .buttonOrangeColor
        return imageView
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstant.LoginInfo.ClosingAppRequired.title
        label.font = .amazonFont(type: .bold, size: 16)
        label.textColor = .lsTetriary
        label.textAlignment = .center
        return label
    }()
    
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        
        let isCustomConfig = UserDefaultsHelper.getAppState() == .loggedIn || UserDefaultsHelper.getAppState() == .customAWSConnected
        if isCustomConfig {
            label.text = StringConstant.LoginInfo.ClosingAppRequired.customConfigSubtitle
        } else {
            label.text = StringConstant.LoginInfo.ClosingAppRequired.defaultConfigSubtitle
        }
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .lsGrey
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        clipsToBounds = true
        layer.cornerRadius = 8
        backgroundColor = .lsLighten.withAlphaComponent(0.14)
        
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-24)
        }
    }
}
