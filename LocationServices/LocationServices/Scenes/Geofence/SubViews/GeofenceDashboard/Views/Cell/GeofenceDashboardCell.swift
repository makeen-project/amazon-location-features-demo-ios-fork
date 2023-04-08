//
//  GeofenceDashboardCell.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

struct GeofenceDashboardCellModel {
    var id: String?
    var name: String?
    
    init(model: GeofenceDataModel) {
        self.id = model.id
        self.name = model.name
    }
}

final class GeofenceDashboardCell: UITableViewCell {
    static let reuseId: String = "geofenceDashboardCell"
    
    var deleteButtonAction: StringHandler?

    var model: GeofenceDashboardCellModel! {
        didSet {
            self.geofenceName.text = model.name
        }
    }
    
    private var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var annotationImage: UIImageView = {
        let iv = UIImageView(image: .geofenceDashoard)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private var geofenceName = AmazonLocationLabel(
        labelText: "",
        font: .amazonFont(type: .regular, size: 16),
        isMultiline: true,
        textAlignment: .left)
    
    private var geofenceEnterMessage = AmazonLocationLabel(
        labelText: "",
        font: .amazonFont(type: .regular, size: 13),
        fontColor: .searchBarTintColor,
        textAlignment: .left)
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.Geofence.deleteGeofenceButton
        button.setImage(.trashIcon, for: .normal)
        button.contentMode = .scaleAspectFill
        button.tintColor = .searchBarTintColor
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(deletaAction), for: .touchUpInside)
        return button
    }()
    
    private var seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .textFieldBackgroundColor
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .searchBarBackgroundColor
        contentView.isUserInteractionEnabled = true
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(annotationImage)
        containerView.addSubview(geofenceName)
        containerView.addSubview(deleteButton)
        containerView.addSubview(seperatorView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        annotationImage.snp.makeConstraints {
            $0.height.width.equalTo(24)
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }
        
        geofenceName.snp.makeConstraints {
            $0.leading.equalTo(annotationImage.snp.trailing).offset(16)
            $0.centerY.equalTo(annotationImage.snp.centerY)
            $0.height.equalTo(28)
        }
            
        deleteButton.snp.makeConstraints {
            $0.height.equalTo(20)
            $0.width.equalTo(18)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-19)
        }
        
        seperatorView.snp.makeConstraints {
            $0.top.equalTo(geofenceName.snp.bottom).offset(11)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    @objc private func deletaAction() {
        if let id = model.id  {
            deleteButtonAction?(id)
        }
    }
}
