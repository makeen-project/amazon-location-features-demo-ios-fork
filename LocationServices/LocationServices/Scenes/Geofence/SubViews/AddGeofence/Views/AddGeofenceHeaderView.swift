//
//  AddGeofenceHeaderView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class AddGeofenceHeaderView: UIView {
    var dismissHandler: VoidHandler?
    private var titleLabel = AmazonLocationLabel(labelText: "Add Geofence",
                                                 font: .amazonFont(type: .bold, size: 20),
                                                 textAlignment: .left)
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.closeIcon, for: .normal)
        button.tintColor = .closeButtonTintColor
        button.backgroundColor = .closeButtonBackgroundColor
        button.isUserInteractionEnabled = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(addGeofenceDismissAction), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    convenience init(isEditinSceneEnabled: Bool) {
        self.init(frame: .zero)
        titleLabel.text = isEditinSceneEnabled ? "Edit Geofence" : "Add Geofence"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.addSubview(titleLabel)
        self.addSubview(closeButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview()
            $0.height.equalTo(28)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview()
            $0.height.width.equalTo(30)
        }
    }
    
    @objc private func addGeofenceDismissAction() {
        self.dismissHandler?()
    }
}
