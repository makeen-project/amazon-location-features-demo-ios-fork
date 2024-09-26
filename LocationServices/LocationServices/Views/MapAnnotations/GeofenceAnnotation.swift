//
//  GeofenceAnnotation.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import MapLibre

//How to use:
//1. Add GeofenceAnnotation to the map
//2. In delegate method
//  func mapView(_ mapView: MLNMapView, viewFor annotation: MLNAnnotation) -> MLNAnnotationView? {
//  create GeofenceAnnotationView for GeofenceAnnotation annotation
//3. In delegate methods
//  func mapView(_ mapView: MLNMapView, didAdd annotationViews: [MLNAnnotationView])
//  func mapViewRegionIsChanging(_ mapView: MLNMapView)
//  func mapView(_ mapView: MLNMapView, regionDidChangeAnimated animated: Bool)
//  call func update(mapView: MLNMapView?) for all geofence annotations.

class GeofenceAnnotation: MLNPointAnnotation {
    var radius: Double = 0
    var id: String?
    
    init(id: String?, radius: Double, title: String?, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.radius = radius
        super.init()
        
        self.title = title
        self.coordinate = coordinate
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class GeofenceAnnotationView: MLNAnnotationView {
    
    enum Constants {
        static let iconSize: CGSize = CGSize(width: 30, height: 30)
    }
    weak private var resizeHandleView: UIView?
    
    weak var mapView: MLNMapView?
    
    private var accuracyRingLayer: CALayer?
    private var oldZoom: Double?
    private var oldRadius: Double?
    
    var enableGeofenceDrag = false
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .amazonFont(type: .regular, size: 11)
        label.textColor = .black
        return label
    }()
    
    func update(mapView: MLNMapView?) {
        if let mapView = mapView,
           self.mapView != mapView {
            self.mapView = mapView
        }
        
        if frame.size.equalTo(.zero) {
            updateFrame()
            addIcon()
            addTitle()
        }
        
        if titleLabel.text != annotation?.title {
            titleLabel.text = annotation?.title ?? nil
        }
        
        drawCircle()
        
        if resizeHandleView == nil && enableGeofenceDrag {
            addResizeHandle()
            positionResizeHandle()
        }
    }
    
    func updateFrame() {
        // Update frame size, keeping the existing center point.
        let oldCenter: CGPoint = self.center
        
        var newFrame: CGRect = self.frame
        newFrame.size = Constants.iconSize
        self.frame = newFrame
        
        self.center = oldCenter
    }
    
    func addTitle() {
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.topAnchor)
        ])
    }
    
    func addIcon() {
        let uiImageView = UIImageView()
        uiImageView.frame = CGRect(origin: .zero, size: frame.size)
        addSubview(uiImageView)
        
        uiImageView.image = .geofenceDashoard
        
        uiImageView.setShadow()
    }

    func drawCircle() {
        guard let mapView,
              let geofenceAnnotation = annotation as? GeofenceAnnotation else { return }
        
        let radius = geofenceAnnotation.radius
        
        if accuracyRingLayer == nil {
            let accuracyRingSize: CGFloat = self.calculateAccuracyRingSize(radius: radius)
            let accuracyRingLayer = self.circleLayer(with: accuracyRingSize)
            accuracyRingLayer.backgroundColor = mapView.tintColor.withAlphaComponent(0.1).cgColor
            accuracyRingLayer.borderColor = mapView.tintColor.cgColor
            accuracyRingLayer.borderWidth = 2
            accuracyRingLayer.shouldRasterize = false
            accuracyRingLayer.allowsGroupOpacity = false
            
            self.layer.addSublayer(accuracyRingLayer)
            self.accuracyRingLayer = accuracyRingLayer
        }
        
        if (accuracyRingLayer != nil && oldZoom != mapView.zoomLevel) ||
            oldRadius != radius {
            
            let accuracyRingSize: CGFloat = self.calculateAccuracyRingSize(radius: radius)
            
            if accuracyRingSize > Constants.iconSize.width {
                accuracyRingLayer?.isHidden = false
                let shouldAnimate = oldRadius != radius
                
                CATransaction.begin()
                CATransaction.setDisableActions(!shouldAnimate)
                
                accuracyRingLayer?.bounds = CGRectMake(0, 0, accuracyRingSize, accuracyRingSize)
                accuracyRingLayer?.cornerRadius = accuracyRingSize / 2.0
                
                CATransaction.commit()
                positionResizeHandle()
            } else {
                self.accuracyRingLayer?.isHidden = true
                self.resizeHandleView?.isHidden = true
                self.accuracyRingLayer = nil
                self.resizeHandleView = nil

            }
            

        }
        
        oldZoom = mapView.zoomLevel
        oldRadius = radius
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
    
    func calculateAccuracyRingSize(radius: CGFloat) -> CGFloat {
        guard let mapView,
              let coordinate = annotation?.coordinate else { return 0 }
        
        return round(radius / mapView.metersPerPoint(atLatitude: coordinate.latitude) * 2.0)
    }
    
    func addResizeHandle() {
            let resizeHandleSize: CGFloat = 20.0
            let resizeHandleView = UIView(frame: CGRect(x: 0, y: 0, width: resizeHandleSize, height: resizeHandleSize))
            resizeHandleView.backgroundColor = mapView?.tintColor
            resizeHandleView.layer.cornerRadius = resizeHandleSize / 2.0
        resizeHandleView.isUserInteractionEnabled = true
        addSubview(resizeHandleView)
        self.bringSubviewToFront(resizeHandleView)
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleResizeHandlePan(_:)))
            resizeHandleView.addGestureRecognizer(panGestureRecognizer)
            self.resizeHandleView = resizeHandleView
        }

        func positionResizeHandle() {
            guard let resizeHandleView = resizeHandleView, let accuracyRingLayer = accuracyRingLayer else { return }
            resizeHandleView.center = CGPoint(x: accuracyRingLayer.cornerRadius+13, y: 10)
        }

        @objc func handleResizeHandlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
            guard let geofenceAnnotation = annotation as? GeofenceAnnotation,
                  let mapView = mapView else { return }

            let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
            let gestureLocation = gestureRecognizer.location(in: self)

            // Calculate the distance between the center of the circle and the gesture location
            let xOffset = center.x - gestureLocation.x
            let yOffset = center.y - gestureLocation.y
            let distance = sqrt(xOffset * xOffset + yOffset * yOffset)

            // Convert points to meters based on the zoom level
            let pointsPerMeter = CGFloat(mapView.metersPerPoint(atLatitude: mapView.centerCoordinate.latitude))
            let updatedRadius = CLLocationDistance(distance * pointsPerMeter)
            
            // Update the geofenceAnnotation radius with some minimum radius constraint
            let minimumRadius: CLLocationDistance = 10
            let maximumRadius: CLLocationDistance = 10000
            geofenceAnnotation.radius = round(max(minimumRadius, min(maximumRadius, updatedRadius)))
            
            let userInfo = ["radius": geofenceAnnotation.radius]
            NotificationCenter.default.post(name: Notification.geofenceRadiusDragged, object: nil, userInfo: userInfo)
            
            drawCircle()
            
            gestureRecognizer.setTranslation(.zero, in: self)
        }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let resizeHandleView = resizeHandleView {
            let pointInResizeHandleView = convert(point, to: resizeHandleView)
            if let result = resizeHandleView.hitTest(pointInResizeHandleView, with: event) {
                return result
            }
        }
        return super.hitTest(point, with: event)
    }
}
