//
//  NoInternetConnectionView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class NoInternetConnectionView: UIView {
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "icloud.slash")
        view.tintColor = .searchBarTintColor
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .amazonFont(type: .bold, size: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = StringConstant.amazonLocatinCannotReach
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = StringConstant.checkYourConnection
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    convenience init() {
        self.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorCannotInitializeView)
    }
    
    private func setupViews() {
        self.addSubview(iconView)
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
       
        iconView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(32)
            $0.width.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview()
        }
    }
}
