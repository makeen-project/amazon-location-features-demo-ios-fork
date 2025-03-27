//
//  TrackingViews.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import MapLibre

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
        static let mapLayerBottomOffset: CGFloat = 16
        static let mapLayerWidth: CGFloat = 50
        
        static let amazonLogoHorizontalOffset: CGFloat = 8
        static let amazonLogoBottomOffset: CGFloat = 8
        static let amazonLogoHeight: CGFloat = 18
        static let amazonLogoWidth: CGFloat = 121
    }
    
    var delegate: TrackingMapViewOutputDelegate? {
        didSet {
            mapView.delegate = delegate
        }
    }
    
    private var isiPad = UIDevice.current.userInterfaceIdiom == .pad
    public var mapView: DefaultCommonMapView = DefaultCommonMapView()
    private var mapLayer: MapOverlayItems = MapOverlayItems()
    
    private var trackingAnnotations: [MLNAnnotation] = []
    
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
        
        setupAmazonLogo(bottomOffset: nil)
        
        infoButton.snp.makeConstraints {
            $0.height.width.equalTo(13.5)
            $0.leading.equalTo(amazonMapLogo.snp.trailing).offset(5)
            $0.centerY.equalTo(amazonMapLogo.snp.centerY)
        }
        
        setupMapLayer(bottomOffset: nil)
    }
    
    func updateBottomViewsSpacings(additionalBottomOffset: CGFloat) {
        let amazonLogoBottomOffset = Constants.amazonLogoBottomOffset + additionalBottomOffset
        setupAmazonLogo(bottomOffset: amazonLogoBottomOffset)
        
        let mapLayerBottomOffset = Constants.mapLayerBottomOffset + additionalBottomOffset
        setupMapLayer(bottomOffset: mapLayerBottomOffset)
    }
    
    private func setupAmazonLogo(bottomOffset: CGFloat?) {
        let bottomOffset = bottomOffset ?? Constants.amazonLogoBottomOffset
        
        amazonMapLogo.snp.remakeConstraints {
            $0.leading.equalToSuperview().offset(Constants.amazonLogoHorizontalOffset)
            if isiPad {
                $0.bottom.equalTo(safeAreaLayoutGuide).inset(bottomOffset)
            } else {
                $0.bottom.equalToSuperview().inset(bottomOffset)
            }
            $0.height.equalTo(Constants.amazonLogoHeight)
            $0.width.equalTo(Constants.amazonLogoWidth)
        }
    }
    
    private func setupMapLayer(bottomOffset: CGFloat?) {
        let bottomOffset = bottomOffset ?? Constants.mapLayerBottomOffset
        mapLayer.snp.remakeConstraints {
            $0.top.equalToSuperview().offset(56)
            $0.trailing.bottom.equalToSuperview()
            if isiPad {
                $0.bottom.equalTo(safeAreaLayoutGuide).inset(bottomOffset)
            } else {
               // $0.bottom.equalToSuperview().inset(bottomOffset)
            }
            $0.width.equalTo(Constants.mapLayerWidth)
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
        mapView.setupMapView(locateMe: false)
        amazonMapLogo.tintColor = GeneralHelper.getAmazonMapLogo()
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
    
    func drawGeofenceCirle(id: String?, lat: Double?, long: Double?, radius: Double, title: String?) {
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
        let dashedLayer = createDashedLayer(source: source, strokeColor: .lsPrimary)
        mapView.draw(layer: dashedLayer, source: source)
        mapView.remove(annotations: trackingAnnotations)
        trackingAnnotations = createTrackingAnnotaions(history)
        mapView.addAnnotations(annotations: trackingAnnotations)
    }
    
    func drawTrackingRoute(routeId: String, coordinates: [CLLocationCoordinate2D]) {
        for i in 1..<coordinates.count {
            createDashLayer(routeId: "\(routeId)-\(i)", coordinates: [coordinates[i-1], coordinates[i]])
        }
        createTrackingAnnotations(sourceId: "\(routeId)-track", coordinates: coordinates, strokeColor: UIColor.lightGray)
    }
    
    func createDashLayer(routeId: String, coordinates: [CLLocationCoordinate2D]) {
        let source = createTrackingSource(coordinates: coordinates, identifier: "\(routeId)-dash-source")
        let dashedLayer = createDashedLayer(source: source, identifier: "\(routeId)-dash-layer", strokeColor: .lsGrey)
        mapView.draw(layer: dashedLayer, source: source)
    }
    
    func updateDashLayer(routeId: String, coordinates: [CLLocationCoordinate2D]) {
        let source = createTrackingSource(coordinates: coordinates, identifier: "\(routeId)-update-dash-source")
        let dashedLayer = createDashedLayer(source: source, identifier: "\(routeId)-update-dash-layer", strokeColor: .lsPrimary)
        mapView.draw(layer: dashedLayer, source: source)
    }
    
    func deleteTrackingRoute(routeId: String, coordinates: [CLLocationCoordinate2D]) {
        guard let style = mapView.mapView.style else { return }
        
        for i in 0..<coordinates.count {
            if let existingSource = style.source(withIdentifier: "\(routeId)-\(i)-dash-source") {
                style.removeSource(existingSource)
            }
            if let existingLayer = style.layer(withIdentifier: "\(routeId)-\(i)-dash-layer") {
                style.removeLayer(existingLayer)
            }
            
            if let existingSource = style.source(withIdentifier: "\(routeId)-\(i)-update-dash-source") {
                style.removeSource(existingSource)
            }
            if let existingLayer = style.layer(withIdentifier: "\(routeId)-\(i)-update-dash-layer") {
                style.removeLayer(existingLayer)
            }
        }

        if let existingSource = style.source(withIdentifier: "\(routeId)-track") {
            style.removeSource(existingSource)
        }
        if let existingLayer = style.layer(withIdentifier: "\(routeId)-track-circle-layer") {
            style.removeLayer(existingLayer)
        }
    }
    
    func deleteUpdateDashLayer(routeId: String) {
        guard let style = mapView.mapView.style else { return }
        if let existingSource = style.source(withIdentifier: "\(routeId)-update-dash-source") {
            style.removeSource(existingSource)
        }
        if let existingLayer = style.layer(withIdentifier: "\(routeId)-update-dash-layer") {
            style.removeLayer(existingLayer)
        }
    }
 
    func addRouteBusAnnotation(id: String, coordinate: CLLocationCoordinate2D) -> ImageAnnotation {
        let busAnnotation = ImageAnnotation(image: UIImage.busAnnotation, identifier: "\(id)-bus")
        busAnnotation.coordinate = coordinate
        mapView.mapView.addAnnotation(busAnnotation)
        return busAnnotation
    }
    
    func updateFeatureColor(at index: Int, sourceId: String, isCovered: Bool) {
        if let routeFeatures = routesFeatures["\(sourceId)-track"] {
            routeFeatures[index].attributes = ["index": index, "isCovered": isCovered ? 1 : 0]
            guard let style = mapView.mapView.style,
                  let source = style.source(withIdentifier: "\(sourceId)-track") as? MLNShapeSource else { return }
            let updatedShapeCollection = MLNShapeCollectionFeature(shapes: routeFeatures)
            source.shape = updatedShapeCollection
        }
    }
    
    @objc private func infoButtonAction() {
        delegate?.showAttribution()
    }
    
    func update(userLocation: CLLocation?, userHeading: CLHeading?) {
        mapView.update(userLocation: userLocation, userHeading: userHeading)
    }
    
    var routesFeatures: [String:[MLNPointFeature]] = [:]
}

private extension TrackingMapView {
    func createTrackingSource(history: [TrackingHistoryPresentation], identifier: String = "tracking-layer") -> MLNSource {
        let coordinates = transformHistoryToCoordinates(history)
        
        let polyline = MLNPolyline(coordinates: coordinates, count: UInt(coordinates.count))
        let source = MLNShapeSource(identifier: identifier, shape: polyline)
        
        return source
    }
    
    func createTrackingSource(coordinates: [CLLocationCoordinate2D], identifier: String) -> MLNSource {
        let polyline = MLNPolyline(coordinates: coordinates, count: UInt(coordinates.count))
        let source = MLNShapeSource(identifier: identifier, shape: polyline)
        
        return source
    }
    
    func transformHistoryToCoordinates(_ history: [TrackingHistoryPresentation]) -> [CLLocationCoordinate2D] {
        return history.compactMap { history -> CLLocationCoordinate2D? in
            let coordinates = history.cooordinates.convertTextToCoordinate()
            guard coordinates.count == 2 else { return nil }
            
            let location = CLLocationCoordinate2D(latitude: coordinates[0], longitude: coordinates[1])
            return location
        }
    }
    
    func createDashedLayer(source: MLNSource, identifier: String = "dashed-layer", strokeColor: UIColor) -> MLNStyleLayer {
        let lineJoinCap = NSExpression(forConstantValue: "round")
        let lineWidth = NSExpression(forConstantValue: 5) //NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",[16: 5, 20: 20])
        
        let dashedLayer = MLNLineStyleLayer(identifier: identifier, source: source)
        dashedLayer.lineJoin = lineJoinCap
        dashedLayer.lineCap = lineJoinCap
        dashedLayer.lineColor = NSExpression(forConstantValue: strokeColor)
        dashedLayer.lineWidth = lineWidth
        dashedLayer.lineDashPattern = NSExpression(forConstantValue: [0, 1.7])
        
        return dashedLayer
    }
    
    func createTrackingAnnotaions(_ history: [TrackingHistoryPresentation]) -> [MLNAnnotation] {
        let coordinates = transformHistoryToCoordinates(history)
        let annotations = coordinates.map {
            let annotation = ImageAnnotation(image: .stepIcon)
            annotation.coordinate = $0
            return annotation
        }
        
        return annotations
    }
    
    func createTrackingAnnotations(sourceId: String, coordinates: [CLLocationCoordinate2D], strokeColor: UIColor) {
        guard let style = mapView.mapView.style else { return }

        // Convert coordinates to MLNPointFeature with properties
        let features = coordinates.enumerated().map { (index, coordinate) -> MLNPointFeature in
            let feature = MLNPointFeature()
            feature.coordinate = coordinate
            feature.attributes = ["index": index, "isCovered": 0]
            return feature
        }
        routesFeatures[sourceId] = features
        
        // Remove old source and layer if they exist
        if let existingSource = style.source(withIdentifier: sourceId) {
            style.removeSource(existingSource)
        }
        if let existingLayer = style.layer(withIdentifier: "\(sourceId)-circle-layer") {
            style.removeLayer(existingLayer)
        }

        // Ensure shape source contains a valid shape collection
        let shapeCollection = MLNShapeCollectionFeature(shapes: features)
        let shapeSource = MLNShapeSource(identifier: sourceId, shape: shapeCollection, options: nil)
        style.addSource(shapeSource)

        // Create the circle layer with dynamic color expression
        let circleLayer = MLNCircleStyleLayer(identifier: "\(sourceId)-circle-layer", source: shapeSource)
        circleLayer.circleRadius = NSExpression(forConstantValue: 4)
        circleLayer.circleColor = NSExpression(forConstantValue: UIColor.white)
        circleLayer.circleStrokeColor = NSExpression(format: "TERNARY(isCovered == 1, %@, %@)", UIColor.lsPrimary, UIColor.lsGrey)
        circleLayer.circleStrokeWidth = NSExpression(forConstantValue: 2)

        style.addLayer(circleLayer)
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
