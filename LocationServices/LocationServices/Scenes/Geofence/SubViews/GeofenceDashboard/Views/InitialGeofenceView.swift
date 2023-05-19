//
//  InitialGeofenceView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class InitialGeofenceView: UIView {
    var geofenceButtonHandler: VoidHandler?
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 48
        return view
    }()
    private let iconView: UIImageView = {
        let iv = UIImageView(image: .geofenceIcon)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let titleLabel = AmazonLocationLabel(labelText: "Geofence",
                                                 font: UIFont.amazonFont(type: .bold, size: 20),
                                                 fontColor: .black,
                                                 textAlignment: .center)
    
    private let detailLabel = AmazonLocationLabel(labelText: """
                                                  Add a geofence to get notified when your device
                                                  enters or exits it
                                                  """,
                                                  font: UIFont.amazonFont(type: .regular, size: 13),
                                                  isMultiline: true,
                                                  fontColor: .searchBarTintColor,
                                                  textAlignment: .center)
    
    private lazy var geofenceButton: AmazonLocationButton =  {
        let button = AmazonLocationButton(title: "Add Geofence")
        button.accessibilityIdentifier = ViewsIdentifiers.Geofence.addGeofenceButtonEmptyList
        button.addTarget(self, action: #selector(addGeofence), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Couldn't initiliza view")
    }
    
    private func setupViews() {
        self.addSubview(iconContainerView)
        iconContainerView.addSubview(iconView)
        self.addSubview(titleLabel)
        self.addSubview(detailLabel)
        self.addSubview(geofenceButton)
        
        iconContainerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(96)
        }
        
        iconView.snp.makeConstraints {
            $0.height.width.equalTo(35)
            $0.centerX.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconContainerView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
        }
        
        detailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.height.equalTo(36)
            $0.leading.trailing.equalToSuperview()
        }
        
        geofenceButton.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(48)
        }
    }
    
    @objc func addGeofence() {
        geofenceButtonHandler?()
    }
}
