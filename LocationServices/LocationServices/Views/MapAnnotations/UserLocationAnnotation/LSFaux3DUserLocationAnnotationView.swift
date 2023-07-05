//
//  LSFaux3DUserLocationAnnotationView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import Mapbox
import CoreLocation

let LSUserLocationAnnotationDotSize: CGFloat = 22.0
let LSUserLocationAnnotationHaloSize: CGFloat = 115.0

let LSUserLocationAnnotationPuckSize: CGFloat = 45.0
let LSUserLocationAnnotationArrowSize: CGFloat = LSUserLocationAnnotationPuckSize * 0.5

let LSUserLocationHeadingUpdateThreshold:CGFloat = 0.01
let LSUserLocationApproximateZoomThreshold:CGFloat = 7.0

class LSFaux3DUserLocationAnnotationView: MGLUserLocationAnnotationView {
    
    // constants
    static let keyFrameTransformScaleXy = "transform.scale.xy"
    static let keyFrameAnimationOpacity = "opacity"
    static let layerKeyAnimateTransformAndOpacity = "animateTransformAndOpacity"
    
    private var _puckModeActivated: Bool = false
    private var _approximateModeActivated: Bool = false
    private var _puckDot: CALayer?
    private var _puckArrow: CAShapeLayer?
    private var _headingIndicatorLayer: LSUserLocationHeadingIndicator?
    private var _accuracyRingLayer: CALayer?
    private var _dotBorderLayer: CALayer?
    private var _dotLayer: CALayer?
    private var _haloLayer: CALayer?
    private var _approximateLayer: CALayer?
    private var _oldHeadingAccuracy: CLLocationDirection = 0
    private var _oldHorizontalAccuracy: CLLocationAccuracy = 0
    private var _oldZoom: Double = 0
    private var _oldPitch: CGFloat = 0
    
    override init(annotation: MGLAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        accessibilityIdentifier = ViewsIdentifiers.General.userLocationAnnotation
    }
    
    func hitTestLayer() -> CALayer? {
        // Only the main dot should be interactive (i.e., exclude the accuracy ring and halo).
        if let _dotBorderLayer {
            return _dotBorderLayer
        } else {
            return _puckDot
        }
    }

    override func update() {
        if frame.size.equalTo(.zero) {
            let frameSize: CGFloat = (self.mapView?.userTrackingMode == .followWithCourse) ? LSUserLocationAnnotationPuckSize : LSUserLocationAnnotationDotSize
            updateFrame(with: frameSize)
        }

        if let coordinates = getCurrentLocation()?.coordinate,
            CLLocationCoordinate2DIsValid(coordinates) {
            if self.mapView?.locationManager.accuracyAuthorization?() == .fullAccuracy {
                self.drawPreciseLocationPuck()
            } else {
                self.drawApproximate()
                self.updatePitch()
            }
        }
    }

    func drawPreciseLocationPuck() {
        if _approximateModeActivated {
            _approximateLayer?.removeFromSuperlayer()
            _approximateLayer = nil
            
            _approximateModeActivated = false
        }
        
        if let mode = (self.mapView?.delegate as? (NavigationMapProtocol & MGLMapViewDelegate))?.mapViewMode(self.mapView) {
            switch mode {
            case .search:
                drawDot()
            case .turnByTurnNavigation:
                drawPuck()
            }
        } else if mapView?.userTrackingMode == .followWithCourse {
            drawPuck()
        } else {
            drawDot()
        }
        
        updatePitch()
        
        if let userLocation = getCurrentLocation() {
            _haloLayer?.isHidden = !CLLocationCoordinate2DIsValid(userLocation.coordinate) || userLocation.horizontalAccuracy > 10
        } else {
            _haloLayer?.isHidden = true
        }
    }

    func setTintColor(tintColor: UIColor) {
        var puckArrowFillColor: UIColor = tintColor
        let puckArrowStrokeColor: UIColor = tintColor

        var approximateFillColor: UIColor = tintColor

        let accuracyFillColor: UIColor = tintColor
        var haloFillColor: UIColor = tintColor
        var dotFillColor: UIColor = tintColor
        var headingFillColor: UIColor = tintColor

        if let mapView,
           let style = mapView.delegate?.mapView?(styleForDefaultUserLocationAnnotationView: mapView) {
            puckArrowFillColor = style.puckArrowFillColor
            approximateFillColor = style.approximateHaloFillColor
            haloFillColor = style.haloFillColor
            dotFillColor = style.puckFillColor
            headingFillColor = style.puckFillColor
        }

        if _puckModeActivated {
            _puckArrow?.fillColor = puckArrowFillColor.cgColor
            _puckArrow?.strokeColor = puckArrowStrokeColor.cgColor
        } else if _approximateModeActivated {
            _approximateLayer?.backgroundColor = approximateFillColor.cgColor
        } else {
            _accuracyRingLayer?.backgroundColor = accuracyFillColor.cgColor
            _haloLayer?.backgroundColor = haloFillColor.cgColor
            _dotLayer?.backgroundColor = dotFillColor.cgColor
            _headingIndicatorLayer?.updateTintColor(headingFillColor.cgColor)
        }
    }

    func updatePitch() {
        guard let mapView,
            mapView.camera.pitch != _oldPitch else { return }
        
        // disable implicit animation
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let t: CATransform3D = CATransform3DRotate(CATransform3DIdentity, MGLRadiansFromDegrees(mapView.camera.pitch), 1.0, 0, 0)
        self.layer.sublayerTransform = t
        
        self.updateFaux3DEffect()
        
        CATransaction.commit()
        
        _oldPitch = mapView.camera.pitch
    }

    func updateFaux3DEffect() {
        let pitch: CGFloat = MGLRadiansFromDegrees(Double(self.mapView?.camera.pitch ?? 0))

        if (_puckDot != nil)
        {
            _puckDot?.shadowOffset = CGSizeMake(0, max(pitch * 10.0, 1.0))
            _puckDot?.shadowRadius = max(pitch * 5.0, 0.75)
        }

        if (_dotBorderLayer != nil)
        {
            _dotBorderLayer?.shadowOffset = CGSizeMake(0.0, pitch * 10.0)
            _dotBorderLayer?.shadowRadius = max(pitch * 5.0, 3.0)
        }

        if (_dotLayer != nil)
        {
            _dotLayer?.zPosition = pitch * 2.0
        }
    }

    func updateFrame(with size: CGFloat) {
        let newSize:CGSize = CGSizeMake(size, size)
        if CGSizeEqualToSize(self.frame.size, newSize)
        {
            return
        }

        // Update frame size, keeping the existing center point.
        let oldCenter:CGPoint = self.center
        var newFrame:CGRect = self.frame
        newFrame.size = newSize
        self.frame = newFrame
        self.center = oldCenter
    }

    func drawPuck() {
        guard let mapView else { return }
        if  !_puckModeActivated {
            self.layer.sublayers = nil

            _headingIndicatorLayer = nil
            _accuracyRingLayer = nil
            _haloLayer = nil
            _dotBorderLayer = nil
            _dotLayer = nil

            self.updateFrame(with: LSUserLocationAnnotationPuckSize)
        }

        var arrowColor: UIColor = mapView.tintColor
        var puckShadowColor: UIColor = UIColor.black
        var shadowOpacity: CGFloat = 0.25

        if let style = mapView.delegate?.mapView?(styleForDefaultUserLocationAnnotationView: mapView) {
            arrowColor = style.puckArrowFillColor
            puckShadowColor = style.puckShadowColor
            shadowOpacity = style.puckShadowOpacity
        }

        // background dot (white with black shadow)
        //
        if  ( _puckDot == nil)
        {
            let _puckDot = self.circleLayer(with: LSUserLocationAnnotationPuckSize)
            _puckDot.backgroundColor = UIColor.white.cgColor
            _puckDot.shadowColor = puckShadowColor.cgColor
            _puckDot.shadowOpacity = Float(shadowOpacity)
            _puckDot.shadowPath = UIBezierPath(ovalIn: _puckDot.bounds).cgPath

            if self.mapView?.camera.pitch != nil {
                self.updateFaux3DEffect()
            } else {
                _puckDot.shadowOffset = CGSizeMake(0, 1)
                _puckDot.shadowRadius = 0.75
            }

            self.layer.addSublayer(_puckDot)
            self._puckDot = _puckDot
        }

        // arrow
        //
        if _puckArrow == nil {
            let _puckArrow = UIImage(named: "navigation-icon")?.cgImage
            let myLayer = CALayer()
            myLayer.frame = super.bounds.insetBy(dx: 10, dy: 10)
            myLayer.contents = _puckArrow
            self.layer.addSublayer(myLayer)
            self.layer.opacity = 0.8
        }
        
        if let location = getCurrentLocation(),
           location.course >= 0 {
            _puckArrow?.setAffineTransform(CGAffineTransformRotate(CGAffineTransformIdentity, -MGLRadiansFromDegrees(mapView.direction - location.course)))
        }

        if !_puckModeActivated {
            _puckModeActivated = true
            self.updateFaux3DEffect()
        }
    }

    func puckArrow() -> UIBezierPath! {
        let max: CGFloat = LSUserLocationAnnotationArrowSize

        let arrowTipY: CGFloat = max*0.05

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: max * 0.5, y: arrowTipY))
        bezierPath.addLine(to: CGPoint(x: max * 0.1, y: max))
        bezierPath.addLine(to: CGPoint(x: max * 0.5, y: max * 0.75))
        bezierPath.addLine(to: CGPoint(x: max, y: max)) // \
        bezierPath.addLine(to: CGPoint(x: max * 0.5, y: arrowTipY))
        bezierPath.close()

        return bezierPath
    }

    func drawDot() {
        guard let mapView else { return }
        if _puckModeActivated
        {
            self.layer.sublayers = nil

            _puckDot = nil
            _puckArrow = nil

            self.updateFrame(with: LSUserLocationAnnotationDotSize)
        }

        var haloColor: UIColor = mapView.tintColor
        var puckBackgroundColor: UIColor = mapView.tintColor
        var puckShadowColor: UIColor = UIColor.black
        var shadowOpacity: CGFloat = 0.25


        if let style = mapView.delegate?.mapView?(styleForDefaultUserLocationAnnotationView: mapView) {
            haloColor = style.haloFillColor
            puckBackgroundColor = style.puckFillColor
            puckShadowColor = style.puckShadowColor
            shadowOpacity = style.puckShadowOpacity
        }

        // heading indicator (tinted, beam or arrow)
        //
        let headingTrackingModeEnabled: Bool = true//mapView.userTrackingMode == .followWithHeading
        let showHeadingIndicator: Bool = mapView.showsUserHeadingIndicator || headingTrackingModeEnabled

        if showHeadingIndicator {
            _headingIndicatorLayer?.isHidden = false
            
            let headingAccuracy: CLLocationDirection? = self.getCurrentHeading()?.headingAccuracy
            
            if ((_headingIndicatorLayer is LSUserLocationHeadingBeamLayer) && !headingTrackingModeEnabled) ||
                ((_headingIndicatorLayer is LSUserLocationHeadingArrowLayer) && headingTrackingModeEnabled) {
                _headingIndicatorLayer?.removeFromSuperlayer()
                _headingIndicatorLayer = nil
                _oldHeadingAccuracy = -1
            }

            if  (_headingIndicatorLayer == nil) && (headingAccuracy != nil) {
                if headingTrackingModeEnabled {
                    let _headingIndicatorLayer = LSUserLocationHeadingBeamLayer(userLocationView:self)
                    _headingIndicatorLayer.updateTintColor(haloColor.cgColor)
                    self.layer.insertSublayer(_headingIndicatorLayer, below:_dotBorderLayer)
                    self._headingIndicatorLayer = _headingIndicatorLayer
                } else {
                    let _headingIndicatorLayer = LSUserLocationHeadingArrowLayer(userLocationView:self)
                    _headingIndicatorLayer.updateTintColor(puckBackgroundColor.cgColor)
                    self.layer.addSublayer(_headingIndicatorLayer)
                    _headingIndicatorLayer.zPosition = 1
                    self._headingIndicatorLayer = _headingIndicatorLayer
                }
            }

            if let headingAccuracy,
               _oldHeadingAccuracy != headingAccuracy {
                _headingIndicatorLayer?.updateHeadingAccuracy(headingAccuracy)
                _oldHeadingAccuracy = headingAccuracy
            }

            var headingDirection: CLLocationDirection? = nil
            if let heading = getCurrentHeading() {
                headingDirection = heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
            }
            
            if let headingDirection,
               headingDirection >= 0 {
                let rotation: CGFloat = -MGLRadiansFromDegrees(mapView.direction - headingDirection)

                // Don't rotate if the change is imperceptible.
                if abs(rotation) > LSUserLocationHeadingUpdateThreshold {
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)

                    _headingIndicatorLayer?.setAffineTransform(CGAffineTransformRotate(CGAffineTransformIdentity, rotation))
                    CATransaction.commit()
                }
            }
        } else {
            _headingIndicatorLayer?.removeFromSuperlayer()
            _headingIndicatorLayer = nil
        }

        // update accuracy ring (if zoom or horizontal accuracy have changed)
        //
        if (_accuracyRingLayer != nil) && (_oldZoom != mapView.zoomLevel || _oldHorizontalAccuracy != self.getCurrentLocation()?.horizontalAccuracy) {
            let accuracyRingSize: CGFloat = self.calculateAccuracyRingSize(zoomLevel: mapView.zoomLevel)

            // only show the accuracy ring if it won't be obscured by the location dot
            if accuracyRingSize > LSUserLocationAnnotationDotSize + 15 {
                _accuracyRingLayer?.isHidden = false

                // disable implicit animation of the accuracy ring, unless triggered by a change in accuracy
                let shouldDisableActions: Bool = _oldHorizontalAccuracy == self.getCurrentLocation()?.horizontalAccuracy

                CATransaction.begin()
                CATransaction.setDisableActions(shouldDisableActions)

                _accuracyRingLayer?.bounds = CGRectMake(0, 0, accuracyRingSize, accuracyRingSize)
                _accuracyRingLayer?.cornerRadius = accuracyRingSize / 2.0

                // match the halo to the accuracy ring
                if let _accuracyRingLayer {
                    _haloLayer?.bounds = _accuracyRingLayer.bounds
                    _haloLayer?.cornerRadius = _accuracyRingLayer.cornerRadius
                }
                _haloLayer?.shouldRasterize = false

                CATransaction.commit()
            } else {
                _accuracyRingLayer?.isHidden = true

                _haloLayer?.bounds = CGRectMake(0, 0, LSUserLocationAnnotationHaloSize, LSUserLocationAnnotationHaloSize)
                _haloLayer?.cornerRadius = LSUserLocationAnnotationHaloSize / 2.0
                _haloLayer?.shouldRasterize = true
                _haloLayer?.rasterizationScale = UIScreen.main.scale
            }

            // store accuracy and zoom so we're not redrawing unchanged location updates
            _oldHorizontalAccuracy = self.getCurrentLocation()?.horizontalAccuracy ?? 0
            _oldZoom = mapView.zoomLevel
        }

        // accuracy ring (circular, tinted, mostly-transparent)
        //
        if  ( _accuracyRingLayer == nil) && self.getCurrentLocation()?.horizontalAccuracy != nil {
            let accuracyRingSize:CGFloat = self.calculateAccuracyRingSize(zoomLevel: mapView.zoomLevel)
            let _accuracyRingLayer = self.circleLayer(with: accuracyRingSize)
            _accuracyRingLayer.backgroundColor = mapView.tintColor.cgColor
            _accuracyRingLayer.opacity = 0.1
            _accuracyRingLayer.shouldRasterize = false
            _accuracyRingLayer.allowsGroupOpacity = false

            self.layer.addSublayer(_accuracyRingLayer)
            self._accuracyRingLayer = _accuracyRingLayer
        }

        // expanding sonar-like pulse (circular, tinted, fades out)
        //
        if  ( _haloLayer == nil)
        {
            let _haloLayer = self.circleLayer(with: LSUserLocationAnnotationHaloSize)
            _haloLayer.backgroundColor = haloColor.cgColor
            _haloLayer.allowsGroupOpacity = false
            _haloLayer.zPosition = -0.1

            // set defaults for the animations
            let animationGroup: CAAnimationGroup! = self.loopingAnimationGroup(with: 3.0)

            // scale out radially with initial acceleration
            let boundsAnimation:CAKeyframeAnimation! = CAKeyframeAnimation(keyPath: LSFaux3DUserLocationAnnotationView.keyFrameTransformScaleXy)
            boundsAnimation.values = [0, 0.35, 1]
            boundsAnimation.keyTimes = [0, 0.2, 1]

            // go transparent as scaled out, start semi-opaque
            let opacityAnimation:CAKeyframeAnimation! = CAKeyframeAnimation(keyPath: LSFaux3DUserLocationAnnotationView.keyFrameAnimationOpacity)
            opacityAnimation.values = [0.4, 0.4, 0]
            opacityAnimation.keyTimes = [0, 0.2, 1]

            animationGroup.animations = [boundsAnimation, opacityAnimation]

            _haloLayer.add(animationGroup, forKey:LSFaux3DUserLocationAnnotationView.layerKeyAnimateTransformAndOpacity)

            self.layer.addSublayer(_haloLayer)
            self._haloLayer = _haloLayer
        }

        // background dot (white with black shadow)
        //
        if  ( _dotBorderLayer == nil)
        {
            let _dotBorderLayer = self.circleLayer(with: LSUserLocationAnnotationDotSize)
            _dotBorderLayer.backgroundColor = UIColor.white.cgColor
            _dotBorderLayer.shadowColor = puckShadowColor.cgColor
            _dotBorderLayer.shadowOpacity = Float(shadowOpacity)
            _dotBorderLayer.shadowPath = UIBezierPath(ovalIn: _dotBorderLayer.bounds).cgPath

//            if mapView.camera.pitch != nil {
            self.updateFaux3DEffect()
//            } else {
//                _dotBorderLayer.shadowOffset = CGSizeMake(0, 0)
//                _dotBorderLayer.shadowRadius = 3
//            }

            self.layer.addSublayer(_dotBorderLayer)
            self._dotBorderLayer = _dotBorderLayer
        }

        // inner dot (pulsing, tinted)
        //
        if  (_dotLayer == nil)
        {
            let _dotLayer = self.circleLayer(with: LSUserLocationAnnotationDotSize * 0.75)
            _dotLayer.backgroundColor = puckBackgroundColor.cgColor

            // set defaults for the animations
            let animationGroup: CAAnimationGroup = self.loopingAnimationGroup(with: 1.5)
            animationGroup.autoreverses = true
            animationGroup.fillMode = CAMediaTimingFillMode.both

            // scale the dot up and down
            let pulseAnimation: CABasicAnimation! = CABasicAnimation(keyPath: "transform.scale.xy")
            pulseAnimation.fromValue = 0.8
            pulseAnimation.toValue = 1

            // fade opacity in and out, subtly
            let opacityAnimation: CABasicAnimation! = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 0.8
            opacityAnimation.toValue = 1

            animationGroup.animations = [pulseAnimation, opacityAnimation]

            _dotLayer.add(animationGroup, forKey:"animateTransformAndOpacity")

            self.layer.addSublayer(_dotLayer)
            self._dotLayer = _dotLayer
        }

        if _puckModeActivated
        {
            _puckModeActivated = false

            self.updateFaux3DEffect()
        }

    }

    func drawApproximate() {
        guard let mapView else { return }
        if !_approximateModeActivated {
            self.layer.sublayers = nil

            _headingIndicatorLayer = nil
            _dotBorderLayer = nil
            _dotLayer = nil
            _accuracyRingLayer = nil
            _haloLayer = nil
            _puckDot = nil
            _puckArrow = nil

            _approximateModeActivated = true
        }

        var backgroundColor: UIColor = mapView.tintColor
        var strokeColor: UIColor = UIColor.black
        var borderSize: CGFloat = 2.0
        var opacity: CGFloat = 0.25

        if let style = mapView.delegate?.mapView?(styleForDefaultUserLocationAnnotationView: mapView) {
            backgroundColor = style.approximateHaloFillColor
            strokeColor = style.approximateHaloBorderColor
            opacity = style.approximateHaloOpacity
            borderSize = style.approximateHaloBorderWidth
        }

        // approximate ring
        if  (_approximateLayer == nil) && self.getCurrentLocation()?.horizontalAccuracy != nil {
            let accuracyRingSize: CGFloat = self.calculateAccuracyRingSize(zoomLevel: max(mapView.zoomLevel, LSUserLocationApproximateZoomThreshold))
            let _approximateLayer = self.circleLayer(with: accuracyRingSize)
            _approximateLayer.backgroundColor = backgroundColor.cgColor
            _approximateLayer.opacity = Float(opacity)
            _approximateLayer.shouldRasterize = false
            _approximateLayer.allowsGroupOpacity = false
            _approximateLayer.borderWidth = borderSize
            _approximateLayer.borderColor = strokeColor.cgColor

            self.layer.addSublayer(_approximateLayer)
            self._approximateLayer = _approximateLayer
        }

        // update approximate ring (if zoom or horizontal accuracy have changed)
        if (_approximateLayer != nil) && (_oldZoom != mapView.zoomLevel || _oldHorizontalAccuracy != self.getCurrentLocation()?.horizontalAccuracy) {
            if mapView.zoomLevel < LSUserLocationApproximateZoomThreshold {
                borderSize = 1.0
            }
            _approximateLayer?.borderWidth = borderSize

            if mapView.zoomLevel >= LSUserLocationApproximateZoomThreshold {
                let accuracyRingSize: CGFloat = self.calculateAccuracyRingSize(zoomLevel: mapView.zoomLevel)

                _approximateLayer?.isHidden = false

                // disable implicit animation of the accuracy ring, unless triggered by a change in accuracy
                let shouldDisableActions: Bool = _oldHorizontalAccuracy == self.getCurrentLocation()?.horizontalAccuracy

                CATransaction.begin()
                CATransaction.setDisableActions(shouldDisableActions)

                _approximateLayer?.bounds = CGRectMake(0, 0, accuracyRingSize, accuracyRingSize)
                _approximateLayer?.cornerRadius = accuracyRingSize / 2.0

                CATransaction.commit()
            }

            // store accuracy and zoom so we're not redrawing unchanged location updates
            _oldHorizontalAccuracy = self.getCurrentLocation()?.horizontalAccuracy ?? 0
            _oldZoom = mapView.zoomLevel
        }
    }

    func circleLayer(with layerSize: CGFloat) -> CALayer {
        let layerSize = layerSize.rounded()

        let circleLayer: CALayer = CALayer()
        circleLayer.bounds = CGRectMake(0, 0, layerSize, layerSize)
        circleLayer.position = CGPointMake(CGRectGetMidX(super.bounds), CGRectGetMidY(super.bounds))
        circleLayer.cornerRadius = layerSize / 2.0
        circleLayer.shouldRasterize = true
        circleLayer.rasterizationScale = UIScreen.main.scale
        circleLayer.drawsAsynchronously = true

        return circleLayer
    }

    func loopingAnimationGroup(with animationDuration: CGFloat) -> CAAnimationGroup {
        let animationGroup: CAAnimationGroup = CAAnimationGroup()
        animationGroup.duration = animationDuration
        animationGroup.repeatCount = .infinity
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)

        return animationGroup
    }

    func calculateAccuracyRingSize(zoomLevel: Double) -> CGFloat {
        guard let mapView,
              let location = getCurrentLocation() else { return 0 }
        // diameter in screen points
        return round(location.horizontalAccuracy / mapView.metersPerPoint(atLatitude: location.coordinate.latitude) * 2.0)
    }
    
    private func getCurrentLocation() -> CLLocation? {
        return self.mapView?.userLocation?.location ?? (self.mapView?.delegate as? NavigationMapProtocol)?.userLocation
    }
    
    private func getCurrentHeading() -> CLHeading? {
        return self.mapView?.userLocation?.heading ?? (self.mapView?.delegate as? NavigationMapProtocol)?.userHeading
    }
}
