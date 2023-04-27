//
//  SideBarCell.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

enum SideBarCellType {
    case explore, tracking, geofence, settings, about
    
    var title: String {
        switch self {
        case .explore: return StringConstant.TabBar.explore
        case .tracking: return StringConstant.TabBar.tracking
        case .geofence: return StringConstant.TabBar.geofence
        case .settings: return StringConstant.TabBar.settings
        case .about: return StringConstant.TabBar.about
        }
    }
    
    var icon: UIImage {
        switch self {
        case .explore: return UIImage.exploreIcon
        case .tracking: return UIImage.trackingIcon
        case .geofence: return UIImage.geofenceIcon
        case .settings: return UIImage.settingsIcon
        case .about: return UIImage.about
        }
    }
}

struct SideBarCellModel {
    let type: SideBarCellType
}

final class SideBarCell: UITableViewCell {

    enum Constants {
        static let itemTitleFont: UIFont = .amazonFont(type: .regular, size: 16)
    }
    
    static let reuseId: String = "SideBarCell"
    
    var model: SideBarCellModel! {
        didSet {
            self.titleLabel.text = model.type.title
            self.iconImageView.image = model.type.icon
        }
    }
    
    
    private var containerView: UIView = UIView()
    
    private var iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .lsGrey
        return iv
    }()
    
    private var titleLabel: UILabel = {
        var label = UILabel()
        label.font = Constants.itemTitleFont
        label.textColor = .lsTetriary
        label.textAlignment = .left
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.height.width.equalTo(20)
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(24)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
