//
//  LSUserLocationHeadingArrowLayer.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import MapLibre

let LSUserLocationHeadingArrowSize: CGFloat = 8

class LSUserLocationHeadingArrowLayer: CAShapeLayer, LSUserLocationHeadingIndicator {

    required init(userLocationView: MLNUserLocationAnnotationView) {
        super.init()
        
        let size: CGFloat = userLocationView.bounds.size.width + LSUserLocationHeadingArrowSize
        self.bounds = CGRectMake(0, 0, size, size)
        self.position = CGPointMake(CGRectGetMidX(userLocationView.bounds), CGRectGetMidY(userLocationView.bounds))
        self.path = self.arrowPath()
        self.fillColor = userLocationView.tintColor.cgColor
        self.shouldRasterize = true
        self.rasterizationScale = UIScreen.main.scale
        self.drawsAsynchronously = true

        self.strokeColor = UIColor.white.cgColor
        self.lineWidth = 1.0
        self.lineJoin = CAShapeLayerLineJoin.round
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    func updateHeadingAccuracy(_ accuracy: CLLocationDirection) {
        // consider to user in the future to improve accuracy
    }

    func updateTintColor(_ color: CGColor) {
        self.fillColor = color
    }

    func arrowPath() -> CGPath {
        let center: CGFloat = self.bounds.midX.rounded()
        let size: CGFloat = LSUserLocationHeadingArrowSize

        let top: CGPoint = CGPointMake(center, 0)
        let left: CGPoint = CGPointMake(center - size, size)
        let right: CGPoint = CGPointMake(center + size, size)
        let middle: CGPoint = CGPointMake(center, size / Double.pi)

        let bezierPath: UIBezierPath = UIBezierPath()
        bezierPath.move(to: top)
        bezierPath.addLine(to: left)
        bezierPath.addQuadCurve(to: right, controlPoint:middle)
        bezierPath.addLine(to: top)
        bezierPath.close()

        return bezierPath.cgPath
    }
}
