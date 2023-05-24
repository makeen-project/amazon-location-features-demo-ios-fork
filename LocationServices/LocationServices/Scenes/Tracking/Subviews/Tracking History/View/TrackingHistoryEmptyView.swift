//
//  TrackingHistoryEmptyView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import SwiftUI

final class TrackingHistoryEmptyView: UIView {

    private let trackingLogo: UIImageView = {
        let imageView = UIImageView(image: .trackingIcon)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var emptyHistoryLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstant.emptyTrackingHistory
        label.textAlignment = .center
        label.font = .amazonFont(type: .regular, size: 15)
        label.textColor = .black
        return label
    }()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .searchBarBackgroundColor
        addSubview(trackingLogo)
        addSubview(emptyHistoryLabel)
        setupConstraints()
    }
    
    private func setupConstraints() {
        let iconSize = CGSize(width: 36, height: 36)
        trackingLogo.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-iconSize.height / 2)
            make.width.equalTo(iconSize.width)
            make.height.equalTo(iconSize.height)
        }
        emptyHistoryLabel.snp.makeConstraints { make in
            make.top.equalTo(trackingLogo.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    
}

