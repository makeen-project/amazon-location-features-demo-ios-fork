//
//  UITableView+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

extension UITableView {
    func setEmptyView(title: String = StringConstant.noMatchingPlacesFound,
                      message: String = StringConstant.searchSpelledCorrectly) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        emptyView.accessibilityIdentifier = ViewsIdentifiers.Search.noResultsView
        let image = UIImageView(image: .searchIcon.withRenderingMode(.alwaysTemplate))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        image.tintColor = .searchBarTintColor
        image.contentMode = .scaleAspectFit
        titleLabel.textColor = UIColor.black
        titleLabel.font = .amazonFont(type: .bold, size: 16)
        titleLabel.textAlignment = .center
        messageLabel.textColor = .searchBarTintColor
        messageLabel.font = .amazonFont(type: .bold, size: 13)
        messageLabel.textAlignment = .center
        emptyView.addSubview(image)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
       
        image.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.height.width.equalTo(40)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(image.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
            $0.height.equalTo(24)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
            $0.height.equalTo(36)
        }
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 2
    
        
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
