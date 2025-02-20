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
    return view
    }()
    
    private var stepImage: UIImageView = {
        let imageView = UIImageView(image: .stepIcon)
        imageView.tintColor = .lsPrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .center
        label.font = .amazonFont(type: .bold, size: 32)
        label.textColor = .lsTetriary
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let streetLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .left
        label.font = .amazonFont(type: .medium, size: 20)
        label.textColor = .lsGrey
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
    
    func updateValues(distance: String?, street: String?, stepImage: UIImage?) {
        if let distance = distance {
            distanceLabel.text = distance
        }
        streetLabel.text = street
        self.stepImage.image = stepImage
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(stepImage)
        containerView.addSubview(distanceLabel)
        containerView.addSubview(streetLabel)
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaInsets)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        stepImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(76)
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(56)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(60)
            $0.leading.equalTo(stepImage.snp.trailing).offset(12)
        }
        
        streetLabel.snp.makeConstraints {
            $0.top.equalTo(distanceLabel.snp.bottom)
            $0.leading.equalTo(stepImage.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-5)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
}
