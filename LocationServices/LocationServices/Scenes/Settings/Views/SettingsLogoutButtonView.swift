//
//  SettingsLogoutButonView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class SettingsLogoutButtonView: UIButton {
    
    private var containerView: UIView = UIView()
    
    private var logoutIcon: UIImageView = {
        let iv = UIImageView(image: .logoutIcon)
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .navigationRedButton
        return iv
    }()
    
    private var itemTitle: UILabel = {
        var label = UILabel()
        label.text = "Log out"
        label.font = .amazonFont(type: .regular, size: 16)
        label.textColor = .mapDarkBlackColor
        label.textAlignment = .left
        return label
    }()
    
    private var arrowIcon: UIImageView = {
        let image = UIImage(systemName: "chevron.right")
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .searchBarTintColor
        return iv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    convenience init() {
        self.init(type: .system)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(logoutIcon)
        containerView.addSubview(arrowIcon)
        containerView.addSubview(itemTitle)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
       
        logoutIcon.snp.makeConstraints {
            $0.height.width.equalTo(20)
            $0.leading.equalToSuperview().offset(25)
            $0.centerY.equalToSuperview()
        }
        
        arrowIcon.snp.makeConstraints {
            $0.height.width.equalTo(14)
            $0.trailing.equalToSuperview().offset(-25)
            $0.centerY.equalToSuperview()
        }
        
        itemTitle.snp.makeConstraints {
            $0.height.equalTo(28)
            $0.leading.equalTo(logoutIcon.snp.trailing).offset(44)
            $0.trailing.equalTo(arrowIcon.snp.leading)
            $0.centerY.equalToSuperview()
        }
    }

}
