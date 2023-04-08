//
//  DeleteTrackingView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class DeleteTrackingView: UIView {
    
    var callback: (()->())?
    
    private let iconView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "data-base-icon")
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
        label.text = StringConstant.trackingDataStorage
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = StringConstant.trackingDisplayData
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.Tracking.deleteTrackingDataButton
        button.setTitleColor(.tabBarTintColor, for: .normal)
        button.setTitle(StringConstant.deleteTrackingData, for: .normal)
        button.titleLabel?.font = UIFont.amazonFont(type: .bold, size: 13)
        button.contentMode = .scaleAspectFit
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
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
    
    @objc func buttonAction() {
        callback?()
    }
    
    private func setupViews() {
        self.addSubview(iconView)
        self.addSubview(titleLabel)
        self.addSubview(subtitleLabel)
        self.addSubview(button)
       
        iconView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(26)
            $0.width.equalTo(24)
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
        }
        
        button.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview()
        }
    }
}
