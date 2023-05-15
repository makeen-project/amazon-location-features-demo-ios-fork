//
//  GeofenceDashboardHeaderView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class GeofenceDashboardHeaderView: UIView {
    
    var addButtonHandler: VoidHandler?
    
    private var containerView: UIView = UIView()
    private var containerTopOffset: CGFloat = 25
    
    private var titleLabel = AmazonLocationLabel(labelText: "Geofence",
                                                 font: .amazonFont(type: .bold, size: 20),
                                                 textAlignment: .left)
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.Geofence.addGeofenceButton
        button.backgroundColor = .lsPrimary
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        return button
    }()
    
    private let addButtonIcon: UIImageView = {
        let image = UIImage(systemName: "plus")!
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .white
        return iv
    }()
    
    private let addButtonLabel: UILabel = {
        let label = UILabel()
        label.text = "Add"
        label.textAlignment = .left
        label.font = .amazonFont(type: .bold, size: 12)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private let buttonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    convenience init(containerTopOffset: CGFloat) {
        self.init(frame: .zero)
        self.containerTopOffset = containerTopOffset
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    @objc func addButtonAction() {
        self.addButtonHandler?()
    }
    
    
    private func setupViews() {
        self.addSubview(containerView)
        addButton.addSubview(buttonContainerView)
        buttonContainerView.addSubview(addButtonIcon)
        buttonContainerView.addSubview(addButtonLabel)
        containerView.addSubview(addButton)
        containerView.addSubview(titleLabel)
       
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(containerTopOffset)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
        
        buttonContainerView.snp.makeConstraints {
            $0.height.equalTo(26)
            $0.width.equalTo(55)
            $0.centerY.centerX.equalToSuperview()
        }
        
        addButtonIcon.snp.makeConstraints {
            $0.height.width.equalTo(16)
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        addButtonLabel.snp.makeConstraints {
            $0.height.equalTo(16)
            $0.leading.equalTo(addButtonIcon.snp.trailing).offset(15)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(32)
            $0.width.equalTo(82)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.equalTo(28)
            $0.centerY.equalTo(addButton.snp.centerY)
        }
    }
}
