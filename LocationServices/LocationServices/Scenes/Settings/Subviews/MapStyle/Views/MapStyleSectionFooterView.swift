//
//  MapStyleSectionFooterView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class MapStyleSectionFooterView: UICollectionReusableView {
    static let reuseId: String = "MapStyleSectionFooterView"
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .closeButtonBackgroundColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
        }
    }
}
