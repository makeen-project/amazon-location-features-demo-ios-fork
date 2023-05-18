//
//  TrackingViews.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import Mapbox

protocol TrackingMapViewDelegate {
    var delegate: GeofenceMapViewOutputDelegate { get set }
}

protocol TrackingMapViewOutputDelegate: BottomSheetPresentable {
    func geofenceButtonAction()
    func showMapLayers()
    func showDirection()
    func showAttribution()
}

final class TrackingMapView: UIView {
    
    enum Constants {
        static let mapLayerBottomOffsetiPad: CGFloat = -8
        static let mapLayerBottomOffsetiPhone: CGFloat = -16
    }
    
    var delegate: TrackingMapViewOutputDelegate? {
        didSet {
            mapView.delegate = delegate
        }
    }
    
    private var isiPad = UIDevice.current.userInterfaceIdiom == .pad
    private var mapView: DefaultCommonMapView = DefaultCommonMapView()
    private var mapLayer: MapOverlayItems = MapOverlayItems()
    
    private var trackingAnnotations: [MGLAnnotation] = []
    
    private let amazonMapLogo: UIImageView = {
        let imageView = UIImageView(image: .amazonLogo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lsGrey
        button.setImage(.infoIcon, for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(infoButtonAction), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        mapLayer.delegate = self
        mapView.delegate = delegate
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        
        self.addSubview(mapView)
        self.addSubview(amazonMapLogo)
        self.addSubview(infoButton)
        self.addSubview(mapLayer)
       
        mapView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        amazonMapLogo.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-8)
            $0.height.equalTo(18)
            $0.width.equalTo(121)
        }
        
        infoButton.snp.makeConstraints {
            $0.height.width.equalTo(13.5)
            $0.leading.equalTo(amazonMapLogo.snp.trailing).offset(5)
            $0.centerY.equalTo(amazonMapLogo.snp.centerY)
        }
        
        mapLayer.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            if isiPad {
                $0.bottom.equalTo(safeAreaLayoutGuide).offset(Constants.mapLayerBottomOffsetiPad)
            } else {
                $0.bottom.equalToSuperview().offset(Constants.mapLayerBottomOffsetiPhone)
            }
            $0.width.equalTo(50)
        }   
    }
    
    func adjustMapLayerItems(bottomSpace: Int) {
        guard !isiPad else { return }
        mapLayer.snp.removeConstraints()
        
        mapLayer.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-bottomSpace)
            $0.width.equalTo(50)
        }
    }
    
    func getUserLocation() -> (lat: Double?, long: Double?) {
        let userLocation = mapView.getUserLocation()
        return (userLocation?.latitude, userLocation?.longitude)
    }
    
    func grantedLocationPermissions() {
        self.mapView.grantedLocationPermissions()
    }
    
    func reloadMap() {
        mapView.setupMapView()
    }
    
    func removeGeofencesFromMap() {
        mapView.removeAllAnnotations()
    }
    
    func showGeofenceAnnotations(_ models: [GeofenceDataModel]) {
        let annotations = models.compactMap { model -> GeofenceAnnotation? in
            guard let radius = model.radius,
                  let lat = model.lat,
                  let long = model.long else { return nil }
            
            let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
            return GeofenceAnnotation(id: model.id, radius: Double(radius), title: model.name, coordinate: coordinates)
        }
        mapView.addAnnotations(annotations: annotations)
    }
    
    func drawGeofenceCirle(id: String?, lat: Double?, long: Double?, radius: Int64, title: String?) {
        mapView.drawGeofenceCircle(id: id, latitude: lat, longitude: long, radius: radius, title: title)
    }
    
    func drawTrack(history: [TrackingHistoryPresentation]) {
        guard !history.isEmpty else {
            mapView.remove(annotations: trackingAnnotations)
            mapView.removeLayer(with: "tracking-layer")
            mapView.removeLayer(with: "dashed-layer")
            return
        }
        let source = createTrackingSource(history: history)
        let dashedLayer = createDashedLayer(source: source)
        mapView.draw(layer: dashedLayer, source: source)
        mapView.remove(annotations: trackingAnnotations)
        trackingAnnotations = createTrackingAnnotaions(history)
        mapView.addAnnotations(annotations: trackingAnnotations)
    }
    
    @objc private func infoButtonAction() {
        delegate?.showAttribution()
    }
    
    func update(userLocation: CLLocation?, userHeading: CLHeading?) {
        mapView.update(userLocation: userLocation, userHeading: userHeading)
    }
}

private extension TrackingMapView {
    func createTrackingSource(history: [TrackingHistoryPresentation], identifier: String = "tracking-layer") -> MGLSource {
        let coordinates = transformHistoryToCoordinates(history)
        
        let polyline = MGLPolyline(coordinates: coordinates, count: UInt(coordinates.count))
        let source = MGLShapeSource(identifier: identifier, shape: polyline)
        
        return source
    }
    
    func transformHistoryToCoordinates(_ history: [TrackingHistoryPresentation]) -> [CLLocationCoordinate2D] {
        return history.compactMap { history -> CLLocationCoordinate2D? in
            let coordinates = history.cooordinates.convertTextToCoordinate()
            guard coordinates.count == 2 else { return nil }
            
            let location = CLLocationCoordinate2D(latitude: coordinates[0].doubleValue, longitude: coordinates[1].doubleValue)
            return location
        }
    }
    
    func createDashedLayer(source: MGLSource, identifier: String = "dashed-layer") -> MGLStyleLayer {
        let lineJoinCap = NSExpression(forConstantValue: "round")
        let lineWidth = NSExpression(
            format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
            [16: 2, 20: 20])
        
        let dashedLayer = MGLLineStyleLayer(identifier: identifier, source: source)
        dashedLayer.lineJoin = lineJoinCap
        dashedLayer.lineCap = lineJoinCap
        dashedLayer.lineColor = NSExpression(forConstantValue: UIColor.lsPrimary)
        dashedLayer.lineWidth = lineWidth
        dashedLayer.lineDashPattern = NSExpression(forConstantValue: [0, 1.5])
        
        return dashedLayer
    }
    
    func createTrackingAnnotaions(_ history: [TrackingHistoryPresentation]) -> [MGLAnnotation] {
        let coordinates = transformHistoryToCoordinates(history)
        let annotations = coordinates.map {
            let annotation = ImageAnnotation(image: .stepIcon)
            annotation.coordinate = $0
            return annotation
        }
        
        return annotations
    }
}

extension TrackingMapView: MapOverlayItemsOutputDelegate {
    func mapLayerButtonAction() {
        delegate?.showMapLayers()
    }
    
    func directionButtonAction() {
        delegate?.showDirection()
    }
    
    func locateMeButtonAction() {
        mapView.locateMeAction()
    }
    
    func geofenceButtonAction() {
        self.delegate?.geofenceButtonAction()
    }
    
    func searchTextTapped() {
        // TODO: Will be implemented later
    }
    
    func loginButtonTapped() {
        // TODO: Will be implemented later
    }
}
