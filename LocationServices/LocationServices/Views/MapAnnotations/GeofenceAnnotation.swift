//
//  GeofenceAnnotation.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import Mapbox

//How to use:
//1. Add GeofenceAnnotation to the map
//2. In delegate method
//  func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
//  create GeofenceAnnotationView for GeofenceAnnotation annotation
//3. In delegate methods
//  func mapView(_ mapView: MGLMapView, didAdd annotationViews: [MGLAnnotationView])
//  func mapViewRegionIsChanging(_ mapView: MGLMapView)
//  func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool)
//  call func update(mapView: MGLMapView?) for all geofence annotations.

class GeofenceAnnotation: MGLPointAnnotation {
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

class GeofenceAnnotationView: MGLAnnotationView {
    
    enum Constants {
        static let iconSize: CGSize = CGSize(width: 30, height: 30)
    }
    
    weak var mapView: MGLMapView?
    
    private var accuracyRingLayer: CALayer?
    private var oldZoom: Double?
    private var oldRadius: Double?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .amazonFont(type: .regular, size: 11)
        label.textColor = .black
        return label
    }()
    
    func update(mapView: MGLMapView?) {
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
            } else {
                accuracyRingLayer?.isHidden = true
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
}
