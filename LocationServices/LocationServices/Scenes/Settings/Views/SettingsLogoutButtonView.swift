//
//  SettingsLogoutButonView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class SettingsLogoutButtonView: UIButton {
    
    enum Constants {
        static let logoutIconSize: CGFloat = 20
        static let logoutIconLeadingOffset: CGFloat = 24
        
        static let arrorIconSize: CGFloat = 14
        static let arrorIconTrailingOffset: CGFloat = 25
        
        static let itemTitleHeight: CGFloat = 28
        static let itemTitleLeadingOffset = 30
    }
    
    private var containerView: UIView = UIView()
    
    private var logoutIcon: UIImageView = {
        let iv = UIImageView(image: .logoutIcon)
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .navigationRedButton
        return iv
    }()
    
    private var itemTitle: UILabel = {
        var label = UILabel()
        label.text = StringConstant.logout
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
        fatalError(.errorInitWithCoder)
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
            $0.height.width.equalTo(Constants.logoutIconSize)
            $0.leading.equalToSuperview().offset(Constants.logoutIconLeadingOffset)
            $0.centerY.equalToSuperview()
        }
        
        arrowIcon.snp.makeConstraints {
            $0.height.width.equalTo(Constants.arrorIconSize)
            $0.trailing.equalToSuperview().offset(-Constants.arrorIconTrailingOffset)
            $0.centerY.equalToSuperview()
        }
        
        itemTitle.snp.makeConstraints {
            $0.height.equalTo(Constants.itemTitleHeight)
            $0.leading.equalTo(logoutIcon.snp.trailing).offset(Constants.itemTitleLeadingOffset)
            $0.trailing.equalTo(arrowIcon.snp.leading)
            $0.centerY.equalToSuperview()
        }
    }

}
