//
//  LSUserLocationHeadingBeamLayer.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import MapLibre

class LSUserLocationHeadingBeamLayer: CALayer, LSUserLocationHeadingIndicator {
    
    private var _maskLayer: CAShapeLayer
    
    required init(userLocationView: MLNUserLocationAnnotationView) {
        _maskLayer = CAShapeLayer()
        super.init()
        
        let size: CGFloat = LSUserLocationAnnotationHaloSize
        self.bounds = CGRectMake(0, 0, size, size)
        self.position = CGPointMake(CGRectGetMidX(userLocationView.bounds), CGRectGetMidY(userLocationView.bounds))
        self.contents = self.gradientImage(with: userLocationView.tintColor.cgColor)
        self.contentsGravity = CALayerContentsGravity.bottom
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0.4
        self.shouldRasterize = true
        self.rasterizationScale = UIScreen.main.scale
        self.drawsAsynchronously = true
        
        _maskLayer.frame = self.bounds
        _maskLayer.path = self.clippingMask(for: 0)
        self.mask = _maskLayer
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    override init(layer: Any) {
        _maskLayer = CAShapeLayer()
        super.init(layer: layer)
    }
    
    func updateHeadingAccuracy(_ accuracy: CLLocationDirection) {
        // recalculate the clipping mask based on updated accuracy
        _maskLayer.path = self.clippingMask(for: accuracy)
    }

    func updateTintColor(_ color: CGColor) {
        // redraw the raw tinted gradient
        self.contents = self.gradientImage(with: color)
    }

    func gradientImage(with tintColor: CGColor) -> CGImage? {
        var image: UIImage?

        let haloRadius:CGFloat = LSUserLocationAnnotationHaloSize / 2.0

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(LSUserLocationAnnotationHaloSize, haloRadius), false, 0)

        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // gradient from the tint color to no-alpha tint color
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: ([tintColor, tintColor.copy(alpha: 0)] as CFArray), locations: [0, 1]) else { return nil }

        // draw the gradient from the center point to the edge (full halo radius)
        let centerPoint: CGPoint = CGPointMake(haloRadius, haloRadius)
        context.drawRadialGradient(gradient,
                                   startCenter: centerPoint, startRadius: 0.0,
                                   endCenter: centerPoint, endRadius: haloRadius, options: .drawsBeforeStartLocation)

        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.cgImage
    }

    func clippingMask(for accuracy: CGFloat) -> CGPath {
        // size the mask using accuracy, but keep within a good display range
        var clippingDegrees:CGFloat = 90 - accuracy
        clippingDegrees = fmin(clippingDegrees, 70) // most accurate
        clippingDegrees = fmax(clippingDegrees, 10) // least accurate

        let ovalRect: CGRect = CGRectMake(0, 0, LSUserLocationAnnotationHaloSize, LSUserLocationAnnotationHaloSize)
        let ovalPath: UIBezierPath = UIBezierPath()

        // clip the oval to ± incoming accuracy degrees (converted to radians), from the top
        ovalPath.addArc(withCenter: CGPointMake(CGRectGetMidX(ovalRect), CGRectGetMidY(ovalRect)),
                            radius:CGRectGetWidth(ovalRect) / 2.0,
                        startAngle:MLNRadiansFromDegrees(-180 + clippingDegrees),
                          endAngle:MLNRadiansFromDegrees(-clippingDegrees),
                         clockwise:true)
        
        let annotationSize = LSUserLocationAnnotationDotSize / 2
        let yPoint = LSUserLocationAnnotationDotSize / 2 + CGRectGetMidY(ovalRect)
        let xPoint = CGRectGetMidX(ovalRect)
        
        ovalPath.addLine(to: CGPoint(x: xPoint + annotationSize, y: yPoint))
        ovalPath.addLine(to: CGPoint(x: xPoint - annotationSize, y: yPoint))
        ovalPath.close()

        return ovalPath.cgPath
    }
}
