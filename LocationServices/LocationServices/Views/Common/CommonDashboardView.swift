//
//  CommonDashboardView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

enum CommonDashoardConstant {
    static let titleFont = UIFont.amazonFont(type: .bold, size: 20)
    static let detailLabelFont = UIFont.amazonFont(type: .regular, size: 13)
}

final class CommonDashboardView: UIView {
    var dashboardButtonHandler: VoidHandler?
    var maybeLaterButtonHander: VoidHandler?
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .searchBarBackgroundColor
        return view
    }()
    private let iconView: UIImageView = {
        let iv = UIImageView(image: .geofenceIcon)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let titleLabel = AmazonLocationLabel(labelText: StringConstant.geofence,
                                                 font: CommonDashoardConstant.titleFont,
                                                 fontColor: .black,
                                                 textAlignment: .center)
    
    private let detailLabel = AmazonLocationLabel(labelText: StringConstant.amazonLocationDetail,
                                                  font: CommonDashoardConstant.detailLabelFont,
                                                  isMultiline: true,
                                                  fontColor: .searchBarTintColor,
                                                  textAlignment: .center)
    
    private lazy var comonButton: AmazonLocationButton =  {
        let button = AmazonLocationButton(title: StringConstant.addGeofence)
        button.accessibilityIdentifier = ViewsIdentifiers.Tracking.enableTrackingButton
        button.addTarget(self, action: #selector(commonButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var maybeLaterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(StringConstant.maybeLater, for: .normal)
        button.titleLabel?.font = UIFont.amazonFont(type: .regular, size: 13)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(maybeLaterAction), for: .touchUpInside)
        button.tintColor = .black
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    convenience init(title: String,
                     detail: String,
                     image: UIImage,
                     iconBackgroundColor: UIColor,
                     buttonTitle: String,
                     titleFont: UIFont = CommonDashoardConstant.titleFont,
                     detailLabelFont: UIFont = CommonDashoardConstant.detailLabelFont) {
        self.init(frame: .zero)
        setupDefaultValues(title: title,
                           detail: detail,
                           image: image,
                           iconBackgroundColor: iconBackgroundColor,
                           buttonTitle: buttonTitle,
                           titleFont: titleFont,
                           detailLabelFont: detailLabelFont)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorCannotInitializeView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconContainerView.layer.cornerRadius = iconContainerView.frame.width / 2
    }
    
    private func setupDefaultValues(title: String,
                                    detail: String,
                                    image: UIImage,
                                    iconBackgroundColor: UIColor,
                                    buttonTitle: String,
                                    titleFont: UIFont?,
                                    detailLabelFont: UIFont?) {
        self.titleLabel.text = title
        self.titleLabel.font = titleFont
        self.detailLabel.text = detail
        self.detailLabel.font = UIFont.amazonFont(type: .regular, size: 13)
        self.iconView.image = image
        self.iconView.backgroundColor = iconBackgroundColor
        self.comonButton.setTitle(buttonTitle, for: .normal)
    }
    
    func hideMaybeLaterButton(state: Bool) {
        self.maybeLaterButton.isHidden = state
    }
    
    private func setupViews() {
        self.addSubview(iconContainerView)
        iconContainerView.addSubview(iconView)
        self.addSubview(titleLabel)
        self.addSubview(detailLabel)
        self.addSubview(maybeLaterButton)
        self.addSubview(comonButton)
        
        iconContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(iconContainerView.snp.width)
            $0.height.lessThanOrEqualTo(96)
            $0.height.equalTo(96).priority(.medium)
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
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        comonButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(detailLabel.snp.bottom).offset(30)
            $0.bottom.equalTo(maybeLaterButton.snp.top).offset(-16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
        }
        
        maybeLaterButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-20)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    @objc func commonButtonAction() {
        dashboardButtonHandler?()
    }
    
    @objc func maybeLaterAction() {
        maybeLaterButtonHander?()
    }
}
