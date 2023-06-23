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
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.setShadow(shadowOpacity: 0.3, shadowBlur: 5)
    return view
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .center
        label.font = .amazonFont(type: .bold, size: 20)
        label.textColor = .lsTetriary
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let streetLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .center
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .lsTetriary
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
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
            $0.top.equalToSuperview().offset(10)
            $0.centerX.leading.trailing.equalToSuperview()
        }
        
        streetLabel.snp.makeConstraints {
            $0.top.equalTo(distanceLabel.snp.bottom).offset(5)
            $0.centerX.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-9)
        }
    }
}
