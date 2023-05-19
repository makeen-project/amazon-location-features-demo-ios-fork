//
//  ExploreMapStyleHeaderView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class ExploreMapStyleHeaderView: UIView {
    private var containerView: UIView = UIView()
    var dismissHandler: VoidHandler?
    
    private var title: LargeTitleLabel = {
        var label = LargeTitleLabel(labelText: StringConstant.mapStyle)
        return label
    }()
    
    private var subtitle: UILabel = {
        var label = UILabel()
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .searchBarTintColor
        label.textAlignment = .left
        label.text = "Changing data provider also affects Places & Routes API"
        return label
    }()
    
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.General.closeButton
        button.setImage(.closeIcon, for: .normal)
        button.tintColor = .closeButtonTintColor
        button.backgroundColor = .closeButtonBackgroundColor
        button.isUserInteractionEnabled = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(exploreMapStyleDismiss), for: .touchUpInside)
        return button
    }()
    
    @objc private func exploreMapStyleDismiss() {
        dismissHandler?()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(title)
        containerView.addSubview(subtitle)
        self.addSubview(closeButton)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        title.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(20)
            $0.height.equalTo(28)
        }
        
        subtitle.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(2)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(18)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.width.equalTo(30)
        }
    }
}
