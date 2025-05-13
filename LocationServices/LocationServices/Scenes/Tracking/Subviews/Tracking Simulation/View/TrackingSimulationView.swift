//
//  TrackingSimulationView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

enum TrackingSimulationConstant {
    static let titleFont = UIFont.amazonFont(type: .bold, size: 20)
    static let detailLabelFont = UIFont.amazonFont(type: .regular, size: 13)
}

final class TrackingSimulationView: UIView {
    var dashboardButtonHandler: VoidHandler?
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private let iconView: UIImageView = {
        let iv = UIImageView(image: .geofenceIcon)
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let titleLabel = AmazonLocationLabel(labelText: "",
                                                 font: TrackingDashoardConstant.titleFont,
                                                 fontColor: .black,
                                                 textAlignment: .center)
    
    private let detailLabel = AmazonLocationLabel(labelText: "",
                                                  font: TrackingDashoardConstant.detailLabelFont,
                                                  isMultiline: true,
                                                  fontColor: .lsGrey,
                                                  textAlignment: .center)
    
    private lazy var comonButton: AmazonLocationButton =  {
        let button = AmazonLocationButton(title: "")
        button.accessibilityIdentifier = ViewsIdentifiers.Tracking.enableTrackingButton
        button.addTarget(self, action: #selector(commonButtonAction), for: .touchUpInside)
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
                     titleFont: UIFont = TrackingDashoardConstant.titleFont,
                     detailLabelFont: UIFont = TrackingDashoardConstant.detailLabelFont) {
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
        self.backgroundColor = .searchBarBackgroundColor
        self.titleLabel.text = title
        self.titleLabel.font = titleFont
        self.detailLabel.text = detail
        self.detailLabel.font = UIFont.amazonFont(type: .regular, size: 13)
        self.iconView.image = image
        self.iconView.backgroundColor = iconBackgroundColor
        self.iconView.tintColor = .black
        self.comonButton.setTitle(buttonTitle, for: .normal)
    }
    
    private func setupViews() {
        self.addSubview(iconContainerView)
        iconContainerView.addSubview(iconView)
        self.addSubview(titleLabel)
        self.addSubview(detailLabel)
        self.addSubview(comonButton)
        
        iconContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
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
            $0.centerX.equalToSuperview()
            $0.width.lessThanOrEqualTo(340)
        }
        
        comonButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(detailLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().offset(-26)
        }
    }
    
    @objc func commonButtonAction() {
        dashboardButtonHandler?()
    }
}
