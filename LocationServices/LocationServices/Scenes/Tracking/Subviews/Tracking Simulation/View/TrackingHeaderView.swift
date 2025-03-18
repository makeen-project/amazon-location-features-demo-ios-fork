//
//  TrackingHeaderView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class TrackingHeaderView: UIView {
    var exitButtonHandler: BoolHandler?
    
    private var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
    return view
    }()
    
    private var trackingImage = PulsatingAnimationView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
    
    private var trackingLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstant.trackersGeofencesHeader
        label.textAlignment = .center
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .lsTetriary
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(StringConstant.exit, for: .normal)
        button.titleLabel?.font = UIFont.amazonFont(type: .regular, size: 13)
        button.tintColor = .black
        button.backgroundColor = .lsLight3
        button.showsMenuAsPrimaryAction = true
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        containerView.addSubview(trackingImage)
        containerView.addSubview(trackingLabel)
        containerView.addSubview(exitButton)
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        trackingImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(24)
        }
        
        trackingLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(trackingImage.snp.trailing).offset(12)
        }
        
        exitButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-4)
            $0.width.equalTo(72)
            $0.height.equalTo(32)
        }
    }
}

class PulsatingAnimationView: UIView {
    
    private let outerCircleLayer = CAShapeLayer()
    private let innerCircleLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        animateOuterCircle()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        animateOuterCircle()
    }
    
    private func setupLayers() {
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)

        // Outer Circle (semi-transparent, pulsating)
        outerCircleLayer.path = UIBezierPath(arcCenter: .zero, radius: 12, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        outerCircleLayer.fillColor = UIColor.lsPrimary.withAlphaComponent(1.0).cgColor
        outerCircleLayer.opacity = 0.2
        outerCircleLayer.position = centerPoint
        layer.addSublayer(outerCircleLayer)
        
        // Inner Circle (solid)
        innerCircleLayer.path = UIBezierPath(arcCenter: .zero, radius: 4, startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
        innerCircleLayer.fillColor = UIColor.lsPrimary.cgColor
        innerCircleLayer.position = centerPoint
        layer.addSublayer(innerCircleLayer)
    }
    
    private func animateOuterCircle() {
        // Scale Animation (Expanding Effect)
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.5
        scaleAnimation.duration = 2.5
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

        // Opacity Animation (Fading Effect)
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.3
        opacityAnimation.toValue = 0.0
        opacityAnimation.duration = 2.5
        opacityAnimation.repeatCount = .infinity
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

        outerCircleLayer.add(scaleAnimation, forKey: "scale")
        outerCircleLayer.add(opacityAnimation, forKey: "opacity")
    }
}

