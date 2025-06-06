//
//  ExploreView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import MapLibre
import CoreLocation

private enum Constants {
    static let mapZoomValue: Double = 20
    static let singleAnnotationMapZoomValue: Double = 17
    static let directionMapZoomValue: Double = 14
    static let annotationMapZoomValue: Double = 10
    static let navigationMapZoomValue: Double = 14
    static let amazonHqMapPosition = (latitude: 47.61506909519956, longitude: -122.33826750882835)
    static let userLocationViewIdentifier = "UserLocationViewIdentifier"
    static let imageAnnotationViewIdentifier = "ImageAnnotationViewIdentifier"
    static let dictinaryKeyIdentityPoolId = "IdentityPoolId"
    
    static let searchBarHeight: CGFloat = 76
    
    static let amazonLogoBottomOffset: CGFloat = 8
    static let amazonLogoHeight: CGFloat = 18
    static let amazonLogoWidth: CGFloat = 121
    static let amazonLogoHorizontalOffset: CGFloat = 8
    
    static let defaultHorizontalOffset: CGFloat = 16
    
    static let actionButtonWidth: CGFloat = 48
    
    static let mapLayerBottomOffset: CGFloat = 16
    static let bottomStackViewOffset: CGFloat = 16
    static let topStackViewOffsetiPhone: CGFloat = 70
    static let topStackViewOffsetiPad: CGFloat = 70
}

enum MapMode {
    case search
    case turnByTurnNavigation
}

protocol NavigationMapProtocol {
    var mapMode: MapMode { get }
    var userLocation: CLLocation? { get }
    var userHeading: CLHeading? { get }
}

final class ExploreView: UIView, NavigationMapProtocol {
    weak var delegate: ExploreViewOutputDelegate?
    var geofenceButtonAction: VoidHandler?
    
    private let debounceForMapRendering = DebounceManager(debounceDuration: 10)
    private(set) var mapMode: MapMode = .search
    private(set) var userLocation: CLLocation?
    private(set) var userHeading: CLHeading?
    private var wasCenteredByUserLocation = false
    private var searchDatas: [MapModel] = []
    
    private var containerView: UIView = UIView()
    
    let searchBarView: SearchBarView = SearchBarView(becomeFirstResponder: true)
    private var isiPad = UIDevice.current.userInterfaceIdiom == .pad
    
    func getSearchBarView() -> SearchBarView {
        return searchBarView
    }
    
    private var mapView: MLNMapView! = {
        let mapView = MLNMapView()
        mapView.tintColor = .lsPrimary
        mapView.compassView.isHidden = true
        mapView.zoomLevel = 12
        mapView.minimumZoomLevel  = 2
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.showsUserHeadingIndicator = false
        mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendering
        return mapView
    }()
    
    private var gridBackgroundView: GridBackgroundView?
    
    private var currentMapHelperViewHeight: UInt = 0
    private let mapHelperView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = ViewsIdentifiers.General.mapHelper
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var directonButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.General.routingButton
        button.tintColor = .maplightGrayColor
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.setImage(.directionMapIcon, for: .normal)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 23,
                                                                      leading: 23,
                                                                      bottom: 23,
                                                                      trailing: 23)
        button.addTarget(self, action: #selector(direactionAction), for: .touchUpInside)
        button.setShadow(shadowOpacity: 0.3, shadowBlur: 5)
        return button
    }()
    
    private lazy var locateMeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .maplightGrayColor
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.setImage(.locateMeMapIcon, for: .normal)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 23,
                                                                      leading: 23,
                                                                      bottom: 23,
                                                                      trailing: 23)
        button.addTarget(self, action: #selector(locateMeAction), for: .touchUpInside)
        button.accessibilityIdentifier = ViewsIdentifiers.General.locateMeButton
        button.setShadow(shadowOpacity: 0.3, shadowBlur: 5)
        return button
    }()
    
    private lazy var geofenceButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .maplightGrayColor
        button.backgroundColor = .white
        button.setImage(.geofenceMapIcon, for: .normal)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 23,
                                                                      leading: 23,
                                                                      bottom: 23,
                                                                      trailing: 23)
        button.addTarget(self, action: #selector(openGeofence), for: .touchUpInside)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private lazy var mapStyleButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.General.mapStyles
        button.tintColor = .maplightGrayColor
        button.backgroundColor = .white
        button.setImage(.mapStyleMapIcon, for: .normal)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 23,
                                                                      leading: 23,
                                                                      bottom: 23,
                                                                      trailing: 23)
        button.addTarget(self, action: #selector(mapStyleAction), for: .touchUpInside)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .mapElementDiverColor
        return view
    }()
    
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
    
    private let bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.spacing = 8
        return stackView
    }()
    
    private let topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .white
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        stackView.setShadow(shadowOpacity: 0.3, shadowBlur: 5)
        stackView.layer.cornerRadius = 8
        stackView.clipsToBounds = true
        stackView.layer.masksToBounds = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityIdentifier = ViewsIdentifiers.Explore.exploreView
        searchBarView.delegate = self
        mapView.delegate = self
        setupMapView()
        createTapGestures()
        setupStackViews()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    func hideGeoFence(state: Bool) {
        geofenceButton.isHidden = state
        dividerView.isHidden = state
    }
    
    func hideMapStyleButton(state: Bool) {
        mapStyleButton.isHidden = state
        dividerView.isHidden = state
    }
    
    func hideDirectionButton(state: Bool) {
        directonButton.isHidden = state
    }
    
    @objc func openGeofence() {
        self.geofenceButtonAction?()
    }
    
    func focusNavigationMode() {
        self.mapMode = .turnByTurnNavigation
        if let userCoordinates = mapView.userLocation?.coordinate,
           CLLocationCoordinate2DIsValid(userCoordinates) {
            mapView.setCenter(userCoordinates, zoomLevel: Constants.navigationMapZoomValue, direction: mapView.direction, animated: true) { [weak self] in
                self?.mapView.userTrackingMode = .followWithCourse
            }
        }
    }
    
    func focus(on coordinates: CLLocationCoordinate2D) {
        guard CLLocationCoordinate2DIsValid(coordinates) else { return }
        mapView.setCenter(coordinates, zoomLevel: Constants.navigationMapZoomValue, direction: mapView.direction, animated: true)
    }
    
    func isLocateMeButtonDisabled(state: Bool, animatedUserLocation: Bool = true) {
        guard !state,
              let userCoordinates = mapView.userLocation?.coordinate,
              CLLocationCoordinate2DIsValid(userCoordinates) else {
            mapView.setCenter(CLLocationCoordinate2D(latitude: Constants.amazonHqMapPosition.latitude, longitude: Constants.amazonHqMapPosition.longitude), zoomLevel: Constants.annotationMapZoomValue, animated: false)
            return
        }
        
        setMapCenter(userCoordinates: userCoordinates, animated: animatedUserLocation)
    }
    
    private func setMapCenter(userCoordinates: CLLocationCoordinate2D, animated: Bool) {
        mapView.setCenter(userCoordinates, zoomLevel: Constants.navigationMapZoomValue, direction: mapView.direction, animated: animated) { [weak self] in
            switch self?.mapMode {
            case .search, .none:
                self?.mapView.userTrackingMode = .follow
            case .turnByTurnNavigation:
                self?.mapView.userTrackingMode = .followWithCourse
            }
        }
    }
    
    func deleteDrawing() {
        self.mapMode = .search
        guard let style = mapView.style else { return }
        
        if let layer =  style.layer(withIdentifier: "polyline") {
            style.removeLayer(layer)
        }
        
        if let layer = style.layer(withIdentifier: "polyline-case") {
            style.removeLayer(layer)
        }
        
        if let layer = style.layer(withIdentifier: "trails-path") {
            style.removeLayer(layer)
        }
        
        if let layer = style.layer(withIdentifier: "dashed-layer-start-point") {
            style.removeLayer(layer)
        }
        
        if let layer = style.layer(withIdentifier: "dashed-layer-end-point") {
            style.removeLayer(layer)
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let annotations = self?.mapView.annotations else { return }
            self?.mapView.removeAnnotations(annotations)
        }
    }
    
    func createTapGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(searchTextFieldAction))
        searchBarView.isUserInteractionEnabled = true
        searchBarView.addGestureRecognizer(tapGesture)
    }
    
    func grantedLocationPermissions() {
        self.mapView.showsUserLocation = true
    }
    
    @objc func searchTextFieldAction() {
        
    }
    
    @objc func direactionAction() {
        locateMeAction()
        delegate?.showDirectionView(userLocation: (mapView.locationManager.authorizationStatus == .authorizedAlways || mapView.locationManager.authorizationStatus == .authorizedWhenInUse) ? mapView.userLocation?.coordinate : nil)
    }
    
    func drawCalculatedRouteWith(_ geoDatas: [Data], departureLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, isRecalculation: Bool, routeType: RouteTypes, isPreview: Bool) {
        DispatchQueue.main.async {
            
            let isDashedLine: Bool
            switch routeType {
            case .pedestrian:
                isDashedLine = true
            case .car, .truck, .scooter:
                isDashedLine = false
            }
            self.createAnnotationsForDirection(departureCoordinates: departureLocation, destinationCoordinates: destinationLocation)
            
            self.drawPolyline(self.mapView, geoDatas: geoDatas, isDashedLine: isDashedLine)
            
            guard !isRecalculation else { return }
            
            var routeCoordinates: [CLLocationCoordinate2D] = []
            for data in geoDatas {
                routeCoordinates.append(contentsOf: self.getCoordinates(from: data))
            }
            let boundsCoordinates = routeCoordinates.isEmpty ? [departureLocation, destinationLocation] : routeCoordinates
            let coordinateBounds = MLNCoordinateBounds.create(from: boundsCoordinates)
            let edgePadding = self.configureMapEdgePadding()
            
            self.mapView.setDirection(0, animated: false)
            self.mapView.setVisibleCoordinateBounds(coordinateBounds, edgePadding: edgePadding, animated: false, completionHandler: nil)
            if let isNavigationMode = UserDefaultsHelper.get(for: Bool.self, key: .isNavigationMode), isNavigationMode {
                if isPreview {
                    self.focusNavigationMode()
                }
                else {
                    self.focus(on: departureLocation)
                }
            }
        }
    }
    
    private func getCoordinates(from geoJson: Data) -> [CLLocationCoordinate2D] {
        guard let shapeFromGeoJSON = try? MLNShape(data: geoJson,
                                                   encoding: String.Encoding.utf8.rawValue) else {
            return []
        }
        let coordinatesPointer = ((shapeFromGeoJSON as? MLNShapeCollectionFeature)?.shapes.first as? MLNPolyline)?.coordinates
        let count = ((shapeFromGeoJSON as? MLNShapeCollectionFeature)?.shapes.first as? MLNPolyline)?.pointCount ?? 0
        let buffer = UnsafeBufferPointer(start: coordinatesPointer, count: Int(count))
        let coordinatesArray = Array(buffer)
        
        return coordinatesArray
    }
    
    private func configureMapEdgePadding() -> UIEdgeInsets {
        let staticInset: CGFloat = 80
        
        let topInset = staticInset + self.safeAreaInsets.top
        let leftInset = staticInset + self.safeAreaInsets.left
        // add small bottom padding on ipad
        let IPAD_INTENTIONAL_BOTTOM_PADDING = CGFloat(200) // Introduces bottom gutter/padding on iPad to assure modals don't overlap with the rendered route
        let IPHONE_INTENTIONAL_BOTTOM_PADDING = CGFloat(500)
        let bottomInset = (self.delegate?.getBottomSheetHeight() ?? 0) + (self.isiPad ? IPAD_INTENTIONAL_BOTTOM_PADDING : IPHONE_INTENTIONAL_BOTTOM_PADDING)
        let rightInset = staticInset + self.safeAreaInsets.right
        
        let edgePadding = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        
        return edgePadding
    }
    
    func shouldBottomStackViewPositionUpdate(state: Bool = false) {
        guard !isiPad else { return }
        if state {
            bottomStackView.snp.remakeConstraints {
                $0.bottom.equalTo(searchBarView.snp.top).offset(-96)
                $0.trailing.equalToSuperview().offset(-16)
                $0.width.equalTo(48)
            }
        } else {
            bottomStackView.snp.remakeConstraints {
                $0.bottom.equalTo(searchBarView.snp.top).offset(-16)
                $0.trailing.equalToSuperview().offset(-16)
                $0.width.equalTo(48)
            }
        }
       setupAmazonLogo(bottomOffset: nil)
    }
    
    func showPlacesOnMapWith(_ mapModel: [MapModel]) {
        self.searchDatas = mapModel
        
        DispatchQueue.main.async { [weak self] in
            if let annotations = self?.mapView.annotations {
                self?.mapView.removeAnnotations(annotations)
            }
            
            let annotationImage: UIImage = mapModel.count == 1 ? .selectedPlace : .annotationIcon
            var points = [ImageAnnotation]()
            mapModel.forEach { model in
                if let lat = model.placeLat, let long = model.placeLong {
                    let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let point = ImageAnnotation(image: annotationImage)
                    point.coordinate = coordinates
                    point.title = model.placeName
                    points.append(point)
                }
            }
            
            self?.mapView.addAnnotations(points)
            if points.count > 1 {
                self?.mapView.showAnnotations(points, animated: false)
            } else if let point = points.first {
                self?.mapView?.setCenter(CLLocationCoordinate2D(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude), zoomLevel: Constants.singleAnnotationMapZoomValue, animated: false)
            }
        }
    }
    
    func show(selectedPlace place: MapModel) {
        showPlacesOnMapWith([place])
        
        guard let lat = place.placeLat, let long = place.placeLong else { return }
        
        let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let point = ImageAnnotation(image: .selectedPlace)
        point.coordinate = coordinates
        point.title = place.placeName
        
        DispatchQueue.main.async { [weak self] in
            self?.showCard(annotation: point)
        }
    }
    
    var mapLoaded = false
    func setupMapView(locateMe: Bool = true) {
        DispatchQueue.main.async { [self] in
            if !mapLoaded {
                mapView.styleURL = DefaultMapStyles.getMapStyleUrl()
                if locateMe {
                    locateMeAction(force: true)
                }
                mapView.showsUserLocation = true
                mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendering
                amazonMapLogo.tintColor = GeneralHelper.getAmazonMapLogo()
            }
        }
    }
    
    func setupTapGesture() {
        let mapTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped))
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            mapTapGestureRecognizer.require(toFail: recognizer)
        }
        mapView.addGestureRecognizer(mapTapGestureRecognizer)
    }
    
    @objc private func infoButtonAction() {
        delegate?.showAttribution()
    }
    
    func update(userLocation: CLLocation?, userHeading: CLHeading?) {
        self.userLocation = userLocation
        self.userHeading = userHeading
        mapView.updateUserLocationAnnotationView()
    }
    
    func updateMapHelperConstraints() {
        let extraSpacing: CGFloat = 70
        let newHeight = calculateMapHelperHeight(topExtraSpacing: extraSpacing)
        guard newHeight != currentMapHelperViewHeight else { return }
        
        mapHelperView.snp.removeConstraints()
        mapHelperView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(extraSpacing)
            $0.leading.trailing.equalToSuperview().inset(extraSpacing)
            $0.height.equalTo(newHeight)
        }
        
        mapHelperView.setNeedsLayout()
        mapHelperView.layoutIfNeeded()
    }
    
    func updateBottomViewsSpacings(additionalBottomOffset: CGFloat) {
        let amazonLogoBottomOffset = Constants.amazonLogoBottomOffset + additionalBottomOffset
        setupAmazonLogo(bottomOffset: amazonLogoBottomOffset)
        
        let mapLayerBottomOffset = Constants.mapLayerBottomOffset + additionalBottomOffset
        setupBottomStack(bottomStackOffset: mapLayerBottomOffset)
    }
    
    func setupAmazonLogo(bottomOffset: CGFloat?) {
        
        let bottomOffset = bottomOffset ?? (isiPad ? 0 : Constants.searchBarHeight) + Constants.bottomStackViewOffset
        
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
    
    private func setupBottomStack(bottomStackOffset: CGFloat?) {
        let bottomStackOffset = bottomStackOffset ?? (isiPad ? 0 : Constants.searchBarHeight) + Constants.bottomStackViewOffset
        
        bottomStackView.snp.remakeConstraints {
            if isiPad {
                $0.bottom.equalTo(safeAreaLayoutGuide).inset(bottomStackOffset)
            } else {
                $0.bottom.equalToSuperview().inset(bottomStackOffset)
            }
            $0.trailing.equalToSuperview().inset(Constants.defaultHorizontalOffset)
            $0.width.equalTo(Constants.actionButtonWidth)
        }
    }
    
    private func calculateMapHelperHeight(topExtraSpacing: CGFloat) -> UInt {
        let topSafeArea = UInt(window?.safeAreaInsets.top ?? 0)
        let bottomOccupiedArea: UInt
        if let bottomSheetHeight = delegate?.getBottomSheetHeight(),
           bottomSheetHeight > 0 {
            bottomOccupiedArea = UInt(bottomSheetHeight)
        } else if let bottomSafeArea = delegate?.getBottomSafeAreaWithTabBarHeight() {
            bottomOccupiedArea = UInt(bottomSafeArea)
        } else {
            bottomOccupiedArea = 0
        }
        
        let areaToSubtract = topSafeArea + bottomOccupiedArea + UInt(topExtraSpacing)
        guard let screenHeight = window?.screen.bounds.height,
              UInt(screenHeight) > areaToSubtract else { return 0 }
        return UInt(screenHeight) - areaToSubtract
    }
}

/// Map View Drawing Functions

private extension ExploreView {
    
    func createAnnotationsForDirection(departureCoordinates: CLLocationCoordinate2D, destinationCoordinates: CLLocationCoordinate2D) {
        if let annotations = mapView.annotations {
            mapView.removeAnnotations(annotations)
        }
        
        var pointsToAdd: [ImageAnnotation] = []
        
        let isDepartureCurrentLocation = departureCoordinates.isCurrentLocation(mapView.userLocation?.coordinate)
        if !isDepartureCurrentLocation {
            let departurePoint = ImageAnnotation(image: .stepIcon)
            departurePoint.coordinate = departureCoordinates
            pointsToAdd.append(departurePoint)
        }
        
        
        let destinationPoint = ImageAnnotation(image: .selectedPlace)
        destinationPoint.coordinate = destinationCoordinates
        pointsToAdd.append(destinationPoint)
        
        self.mapView.addAnnotations(pointsToAdd)
    }
    
    func drawPolyline(_ mapView: MLNMapView, geoDatas: [Data], isDashedLine: Bool) {
        // Ensure the style is loaded
        guard let style = mapView.style else { return }

        // Remove existing layers if any
        ["polyline", "polyline-case", "trails-path"].forEach { layerID in
            if let layer = style.layer(withIdentifier: layerID) {
                style.removeLayer(layer)
            }
        }

        // Convert each GeoJSON Data into an MLNShape and add to the array of shapes
        let shapes: [MLNShape] = geoDatas.compactMap { data in
            return try? MLNShape(data: data, encoding: String.Encoding.utf8.rawValue)
        }
        
        // Create source from the combined shape and add it to the style
        let source = MLNShapeSource(identifier: "polyline-source", shapes: shapes, options: nil)
        if let existingSource = style.source(withIdentifier: "polyline-source") {
            style.removeSource(existingSource)
        }
        style.addSource(source)

        // Prepare layer parameters
        let lineJoinCap = NSExpression(forConstantValue: "round")
        let lineWidth = NSExpression(
            format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
            [16: 4, 20: 20]
        )
        let lineColor = UIColor(hex: "#008296")

        // Create layers based on the dashed line option
        if isDashedLine {
            let dashedLayer = createDashLayer(source, withLineJoinCap: lineJoinCap, withLineWidth: lineWidth, color: lineColor)
            
            if let symbolLayer = style.layers.last {
                style.insertLayer(dashedLayer, below: symbolLayer)
            } else {
                style.addLayer(dashedLayer)
            }
        } else {
            let layer = createLayer(source, withLineJoinCap: lineJoinCap, withLineWidth: lineWidth)
            let casingLayer = createCasingLayer(source, withLineJoinCap: lineJoinCap)
            
            if let symbolLayer = style.layers.last {
                style.insertLayer(layer, below: symbolLayer)
            } else {
                style.addLayer(layer)
            }
            style.insertLayer(casingLayer, below: layer)
        }
    }
    
    func drawDashedLine(_ mapView: MLNMapView, geoJsonArray: [Data], departureCoordinates: CLLocationCoordinate2D, destinationCoordinates: CLLocationCoordinate2D) {
        guard let style = mapView.style else { return }
        
        // Convert each GeoJSON Data into an MLNShape and combine into one shape collection
        let shapes = geoJsonArray.compactMap { geoJson -> MLNShape? in
            return try? MLNShape(data: geoJson, encoding: String.Encoding.utf8.rawValue)
        }
        
        // Create a collection feature from all shapes
        let combinedShape = MLNShapeCollectionFeature(shapes: shapes)
        
        // Draw the dashed line for the combined shape
        drawDashedLine(style, combinedShape: combinedShape, point: departureCoordinates, isFirst: true)
        drawDashedLine(style, combinedShape: combinedShape, point: destinationCoordinates, isFirst: false)
    }
    
    func drawDashedLine(_ mapView: MLNMapView, geoJson: Data, departureCoordinates: CLLocationCoordinate2D, destinationCoordinates: CLLocationCoordinate2D) {
        guard let style = mapView.style else { return }
        
        let shapeFromGeoJSON = (try? MLNShape(data: geoJson,
                                              encoding: String.Encoding.utf8.rawValue)) ?? MLNShape()
        
        drawDashedLine(style, combinedShape: shapeFromGeoJSON, point: departureCoordinates, isFirst: true)
        drawDashedLine(style, combinedShape: shapeFromGeoJSON, point: destinationCoordinates, isFirst: false)
    }
    
    func drawDashedLine(_ style: MLNStyle, combinedShape: MLNShape, point: CLLocationCoordinate2D, isFirst: Bool) {
        // Remove any existing layers or sources
        let sourceName = "dashed-source-combined"
        let layerName = "dashed-layer-combined"
        
        if let existingLayer = style.layer(withIdentifier: layerName) {
            style.removeLayer(existingLayer)
        }
        if let existingSource = style.source(withIdentifier: sourceName) {
            style.removeSource(existingSource)
        }
        
        // Create and add the source
        guard let source = createDashedSource(combinedShape: combinedShape, point: point, isFirst: true, identifier: sourceName) else { return }
        style.addSource(source)
        
        // Prepare and add the dashed layer with required styling
        let lineJoinCap = NSExpression(forConstantValue: "round")
        let lineWidth = NSExpression(
            format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
            [16: 2, 20: 20])
        
        let dashedLayer = createDashLayer(source, withLineJoinCap: lineJoinCap, withLineWidth: lineWidth, color: .gray, identifier: layerName)
        
        if let symbolLayer = style.layers.last {
            style.insertLayer(dashedLayer, below: symbolLayer)
        } else {
            style.addLayer(dashedLayer)
        }
    }
    
    func createDashedSource(combinedShape: MLNShape, point firstPoint: CLLocationCoordinate2D, isFirst: Bool, identifier: String) -> MLNSource? {
        guard let secondPoint = findCoordinate(in: combinedShape, isFirst: isFirst) else { return nil }
        
        let firstLocation = CLLocation(location: firstPoint)
        let secondLocation = CLLocation(location: secondPoint)
        
        let acceptableDifferenceInMeters: Double = 3
        guard firstLocation.distance(from: secondLocation) > acceptableDifferenceInMeters else { return nil }
        
        let polyline = MLNPolyline(coordinates: [firstPoint, secondPoint], count: 2)
        let source = MLNShapeSource(identifier: identifier, shape: polyline)
        
        return source
    }
    
    func findCoordinate(in shape: MLNShape, isFirst: Bool) -> CLLocationCoordinate2D? {
        if let polyline = shape as? MLNPolyline,
           polyline.pointCount > 0 {
            if isFirst {
                return polyline.coordinates[0]
            } else {
                return polyline.coordinates[Int(polyline.pointCount) - 1]
            }
        } else if let shapeCollection = shape as? MLNShapeCollectionFeature {
            for shape in shapeCollection.shapes {
                if let coordinate = findCoordinate(in: shape, isFirst: isFirst) {
                    return coordinate
                }
            }
        }
        return nil
    }
    
    func createSource(_ style: MLNStyle, fromShape shape: MLNShape) -> MLNSource {
        let source = MLNShapeSource(identifier: UUID().uuidString, shape: shape, options: nil)
        style.addSource(source)
        return source
    }
    
    func createLayer(_ source: MLNSource, withLineJoinCap lineJoinCap: NSExpression, withLineWidth lineWidth: NSExpression) -> MLNStyleLayer {
        // Create new layer for the line.
        let layer = MLNLineStyleLayer(identifier: "polyline", source: source)
        layer.lineJoin = lineJoinCap
        layer.lineCap = lineJoinCap
        // Set the line color to a constant blue color.
        layer.lineColor = NSExpression(forConstantValue:UIColor(hex: "#008296"))
        layer.lineWidth = lineWidth
        
        return layer
    }
    
    func createCasingLayer(_ source: MLNSource, withLineJoinCap lineJoinCap: NSExpression) -> MLNStyleLayer {
        // We can also add a second layer that will draw a stroke around the original line.
        let casingLayer = MLNLineStyleLayer(identifier: "polyline-case", source: source)
        // Copy these attributes from the main line layer.
        casingLayer.lineJoin = lineJoinCap
        casingLayer.lineCap = lineJoinCap
        // Line gap width represents the space before the outline begins, so should match the main line’s line width exactly.
        casingLayer.lineGapWidth = casingLayer.lineWidth
        // Stroke color slightly darker than the line color.
        casingLayer.lineColor = NSExpression(forConstantValue: UIColor(red: 41/255, green: 145/255, blue: 171/255, alpha: 1))
        // Use `NSExpression` to gradually increase the stroke width between zoom levels 14 and 18.
        casingLayer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [14: 1, 18: 4])
        
        return casingLayer
    }
    
    func createDashLayer(_ source: MLNSource, withLineJoinCap lineJoinCap: NSExpression, withLineWidth lineWidth: NSExpression, color: UIColor = .white, identifier: String = "trails-path") -> MLNStyleLayer {
        let dashedLayer = MLNLineStyleLayer(identifier: identifier, source: source)
        dashedLayer.lineJoin = lineJoinCap
        dashedLayer.lineCap = lineJoinCap
        dashedLayer.lineColor = NSExpression(forConstantValue: color)
        dashedLayer.lineWidth = lineWidth
        // Dash pattern in the format [dash, gap, dash, gap, ...]. You’ll want to adjust these values based on the line cap style.
        dashedLayer.lineDashPattern = NSExpression(forConstantValue: [0, 1.5])
        
        return dashedLayer
    }
}

private extension ExploreView {
    
    func setupStackViews() {
        topStackView.removeArrangedSubViews()
        bottomStackView.removeArrangedSubViews()
        topStackView.addArrangedSubview(mapStyleButton)
        topStackView.addArrangedSubview(dividerView)
        topStackView.addArrangedSubview(geofenceButton)
        bottomStackView.addArrangedSubview(locateMeButton)
        bottomStackView.addArrangedSubview(directonButton)
    }
    
    func setupViews() {
        self.addSubview(mapHelperView)
        self.addSubview(containerView)
        self.addSubview(searchBarView)
        self.addSubview(amazonMapLogo)
        self.addSubview(infoButton)
                
        gridBackgroundView = GridBackgroundView(frame: self.bounds)
        gridBackgroundView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(gridBackgroundView!)
        
    
        
        containerView.addSubview(mapView)
        containerView.addSubview(topStackView)
        containerView.addSubview(bottomStackView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        searchBarView.snp.makeConstraints {
            $0.height.equalTo(Constants.searchBarHeight)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        setupAmazonLogo(bottomOffset: (isiPad ? 0 : Constants.searchBarHeight) + Constants.bottomStackViewOffset)
        
        infoButton.snp.makeConstraints {
            $0.height.width.equalTo(13.5)
            $0.leading.equalTo(amazonMapLogo.snp.trailing).offset(5)
            $0.centerY.equalTo(amazonMapLogo.snp.centerY)
        }
        
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        geofenceButton.snp.makeConstraints {
            $0.height.width.equalTo(Constants.actionButtonWidth)
        }
        
        dividerView.snp.makeConstraints {
            $0.height.width.equalTo(1)
        }
        
        mapStyleButton.snp.makeConstraints {
            $0.height.width.equalTo(Constants.actionButtonWidth)
        }
        
        topStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(
                isiPad ? Constants.topStackViewOffsetiPad : Constants.topStackViewOffsetiPhone
            )
            $0.trailing.equalToSuperview().offset(-Constants.defaultHorizontalOffset)
            $0.width.equalTo(Constants.actionButtonWidth)
        }
        
        directonButton.snp.makeConstraints {
            $0.height.width.equalTo(Constants.actionButtonWidth)
        }
        
        locateMeButton.snp.makeConstraints {
            $0.height.width.equalTo(Constants.actionButtonWidth)
        }
        
        setupBottomStack(bottomStackOffset: nil)
        setupAmazonLogo(bottomOffset: nil)
        updateMapHelperConstraints()
    }
}

private extension ExploreView {
    @objc func locateMeAction(force: Bool = false) {
        let action = { [weak self] in
            guard let self else { return }
            let state = self.mapView.locationManager.authorizationStatus == .authorizedWhenInUse
            self.isLocateMeButtonDisabled(state: !state, animatedUserLocation: !force)
        }
        
        guard !force else {
            action()
            return
        }
        
        delegate?.performLocationDependentAction {
            action()
        }
    }
    
    @objc func mapStyleAction() {
        delegate?.showMapStyles()
    }
    
    @objc func mapViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard mapMode == .search else { return }
        let tapPoint = gestureRecognizer.location(in: mapView)
        let location = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        delegate?.showPoiCard(for: location)
    }
}

extension ExploreView: MLNMapViewDelegate {

    func mapView(_ mapView: MLNMapView, regionDidChangeWith reason: MLNCameraChangeReason, animated: Bool) {
        UserDefaultsHelper.saveObject(value: LocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude), key: .mapCenter)
    }
    
    func mapView(_ mapView: MLNMapView, didSelect annotation: MLNAnnotation) {
        guard mapMode == .search else { return }
        showCard(annotation: annotation, mapView: mapView)
    }
    
    private func showCard(annotation: MLNAnnotation, mapView: MLNMapView? = nil) {
        let cardData = searchDatas.filter {$0.placeLong == annotation.coordinate.longitude && $0.placeLat == annotation.coordinate.latitude}
        
        if let zoomData = cardData[safe: 0], let lat = zoomData.placeLat, let long = zoomData.placeLong {
            mapView?.setCenter(CLLocationCoordinate2D(latitude: lat, longitude: long), zoomLevel: Constants.singleAnnotationMapZoomValue, animated: false)
        }
        
        delegate?.showPoiCard(cardData: cardData)
    }
    
    func mapView(_ mapView: MLNMapView, viewFor annotation: MLNAnnotation) -> MLNAnnotationView? {
        switch annotation {
        case is MLNUserLocation:
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.userLocationViewIdentifier) {
                annotationView.annotation = annotation
                return annotationView
            } else {
                return LSFaux3DUserLocationAnnotationView(annotation: annotation, reuseIdentifier: Constants.userLocationViewIdentifier)
            }
        case is ImageAnnotation:
            guard let imageAnnotation = annotation as? ImageAnnotation else { return nil }
            let imageAnnotationView: MLNAnnotationView
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.imageAnnotationViewIdentifier) as? ImageAnnotationView {
                annotationView.annotation = imageAnnotation
                annotationView.addImage(imageAnnotation.image)
                
                imageAnnotationView = annotationView
            } else {
                imageAnnotationView = ImageAnnotationView(annotation: imageAnnotation, reuseIdentifier: Constants.imageAnnotationViewIdentifier)
            }
            
            imageAnnotationView.accessibilityIdentifier = ViewsIdentifiers.General.imageAnnotationView
            return imageAnnotationView
        default:
            return nil
        }
    }
    
    func mapView(_ mapView: MLNMapView, didUpdate userLocation: MLNUserLocation?) {
        switch mapMode {
        case .search:
            guard !wasCenteredByUserLocation,
                  let userCoordinates = userLocation?.coordinate else { return }
            
            wasCenteredByUserLocation = true
            setMapCenter(userCoordinates: userCoordinates, animated: true)
        case .turnByTurnNavigation:
            guard let userCoordinates = userLocation?.coordinate else { return }
            delegate?.userLocationChanged(userCoordinates)
        }
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MLNMapView) {
        mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendering
        containerView.bringSubviewToFront(gridBackgroundView!)
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MLNMapView, fullyRendered: Bool) {
        if(gridBackgroundView != nil){
            containerView.sendSubviewToBack(gridBackgroundView!)
            gridBackgroundView?.isHidden = true
            gridBackgroundView = nil
        }
        if fullyRendered {
            debounceForMapRendering.debounce { [weak self] in
                self?.updateMapHelperConstraints()
                self?.mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendered
                self?.mapLoaded = true
                
            }
        } else {
            debounceForMapRendering.debounce {}
            mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendering
        }
    }
    
    func mapViewWillStartRenderingFrame(_ mapView: MLNMapView) {
        mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendering

    }
    
    func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
        GeneralHelper.setMapLanguage(mapView: mapView, style: style)
    }
    
    //frame callback called multiple times even before all map layers are rendered. The fullRendered propery also isn't reliable as it sends true state before map fully rendered. Based on this debounce manager is used here to overcome these issues.
    func mapViewDidFinishRenderingFrame(_ mapView: MLNMapView, fullyRendered: Bool) {
        if fullyRendered {
            if let style = mapView.style {
                GeneralHelper.setMapLanguage(mapView: mapView, style: style)
            }
            debounceForMapRendering.debounce { [weak self] in
                self?.updateMapHelperConstraints()
                self?.mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendered
            }
        } else {
            debounceForMapRendering.debounce {}
            mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendering
        }
    }
}

extension ExploreView: SearchBarViewOutputDelegate {
    func searchTextActivated() {
        delegate?.searchTextTapped(userLocation: mapView.userLocation?.coordinate)
    }
    
    func searchTextDeactivated() {
        // TODO: Will be implemented later
    }
}

extension ExploreView: ExploreViewDelegate {
    func getUserLocation() {
        print("Locate User")
    }
}
