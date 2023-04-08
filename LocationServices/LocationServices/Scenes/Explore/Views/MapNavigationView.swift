//
//  MapNavigationView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class MapNavigationView: UIView {
    
    private var containerView: UIView = {
        
       let view = UIView()
        view.backgroundColor = .tabBarTintColor
        view.layer.cornerRadius = 8
        return view
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = .amazonFont(type: .bold, size: 24)
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let streetLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textAlignment = .center
        label.font = .amazonFont(type: .regular, size: 16)
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateValues(distance: String?, street: String?) {
        distanceLabel.text = distance
        streetLabel.text = street
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(distanceLabel)
        containerView.addSubview(streetLabel)
        
        containerView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        distanceLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.centerX.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        streetLabel.snp.makeConstraints {
            $0.top.equalTo(distanceLabel.snp.bottom)
            $0.centerX.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-11)
        }
    }
}
