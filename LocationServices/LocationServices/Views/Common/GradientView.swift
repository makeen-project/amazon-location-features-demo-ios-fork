//
//  GradientView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

class GradientView: UIView {
    private let colors: [UIColor]
    private let startPoint: CGPoint
    private let endPoint: CGPoint
    private let locations: [NSNumber]
    
    private var gradient: CAGradientLayer?
    
    init(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint, locations: [NSNumber]) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.locations = locations
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let gradient = self.gradient ?? CAGradientLayer()
        gradient.frame = bounds
        
        let shouldApplyStyle = self.gradient == nil
        if shouldApplyStyle {
            gradient.colors = colors.map({ $0.cgColor })
            gradient.startPoint = startPoint
            gradient.endPoint = endPoint
            gradient.locations = locations
        }
        
        if shouldApplyStyle {
            layer.insertSublayer(gradient, at: 0)
        }
        self.gradient = gradient
    }
}
