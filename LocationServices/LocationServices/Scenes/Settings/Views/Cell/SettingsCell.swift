//
//  SettingsCell.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

enum SettingsCellType {
    case units,dataProvider, mapStyle, routeOption, resetPassword, awsCloud
    
    var title: String {
        switch self {
        case .units:
            return StringConstant.units
        case .dataProvider:
            return StringConstant.dataProvider
        case .mapStyle:
            return StringConstant.mapStyle
        case .routeOption:
            return StringConstant.defaultRouteOptions
        case .resetPassword:
            return StringConstant.resetPassword
        case .awsCloud:
            return StringConstant.connectYourAWSAccount
        }
    }
    
    var itemIcon: UIImage {
        switch self {
        case .units:
            return .unitIcons
        case .dataProvider:
            return .dataProviderIcon
        case .mapStyle:
            return .mapStyleIcon
        case .routeOption:
            return .routeOption
        case .resetPassword:
            return .resetPasswordIcon
        case .awsCloud:
            return .awsCloudFormationIcon
        }
    }
}

struct SettingsCellModel {
    var type: SettingsCellType
    var subTitle: String?
}

final class SettingsCell: UITableViewCell {

    static let settingCellReuseId: String = "settingsCell"
    
    var data: SettingsCellModel! {
        didSet {
            self.accessibilityIdentifier = data.type.title
            self.itemIcon.image = data.type.itemIcon
            self.itemTitle.text = data.type.title
            self.itemSubtitle.isHidden = data.subTitle != nil ? false : true
            self.itemSubtitle.text = data.subTitle
        }
    }
    
    
    private var containerView: UIView = UIView()
    
    private var selectionView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = .settingsSelectionColor
        return view
    }()
    
    private var itemIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .searchBarTintColor
        return iv
    }()
    
    private var itemTitle: UILabel = {
        var label = UILabel()
        label.font = .amazonFont(type: .regular, size: 16)
        label.textColor = .mapDarkBlackColor
        label.textAlignment = .left
        return label
    }()
    
    
    private var itemSubtitle: UILabel = {
        var label = UILabel()
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .searchBarTintColor
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
    
    private var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.tintColor = .clear
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if UIDevice.current.userInterfaceIdiom == .pad {
            selectionView.isHidden = !selected
        }
    }
    
    private func setupViews() {

        textStackView.removeArrangedSubViews()
        textStackView.addArrangedSubview(itemTitle)
        textStackView.addArrangedSubview(itemSubtitle)
        
        self.addSubview(selectionView)
        selectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.addSubview(containerView)
        containerView.addSubview(itemIcon)
        containerView.addSubview(arrowIcon)
        containerView.addSubview(textStackView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        itemIcon.snp.makeConstraints {
            $0.height.width.equalTo(22)
            $0.leading.equalToSuperview().offset(18)
            $0.centerY.equalToSuperview()
        }
        
        arrowIcon.snp.makeConstraints {
            $0.height.width.equalTo(14)
            $0.trailing.equalToSuperview().offset(-25)
            $0.centerY.equalToSuperview()
        }
        
        textStackView.snp.makeConstraints {
            $0.height.equalTo(46)
            $0.leading.equalTo(itemIcon.snp.trailing).offset(24)
            $0.trailing.equalTo(arrowIcon.snp.leading)
            $0.centerY.equalToSuperview()
        }
    }
}
