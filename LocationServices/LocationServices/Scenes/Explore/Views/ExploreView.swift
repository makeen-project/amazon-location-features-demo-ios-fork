//
//  ExploreView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import Mapbox
import CoreLocation
import AWSMobileClientXCF

private enum Constant {
    static let mapZoomValue: Double = 20
    static let singleAnnotationMapZoomValue: Double = 17
    static let directionMapZoomValue: Double = 14
    static let annotationMapZoomValue: Double = 10
    static let navigationMapZoonValue: Double = 14
    static let amazonHqMapPosition = (latitude: 47.61506909519956, longitude: -122.33826750882835)
    static let userLocationViewIdentifier = "UserLocationViewIdentifier"
    static let imageAnnotationViewIdentifier = "ImageAnnotationViewIdentifier"
    static let dictinaryKeyIdentityPoolId = "IdentityPoolId"
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
    
    private var signingDelegate: MGLOfflineStorageDelegate?
    private var containerView: UIView = UIView()
    
    let searchBarView: SearchBarView = SearchBarView(becomeFirstResponder: true)
    private var isiPad = UIDevice.current.userInterfaceIdiom == .pad
    
    func getSearchBarView() -> SearchBarView {
        return searchBarView
    }
    
    private var mapView: MGLMapView! = {
        let mapView = MGLMapView()
        mapView.tintColor = .tabBarTintColor
        mapView.compassView.isHidden = true
        mapView.zoomLevel = 12
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.showsUserHeadingIndicator = false
        mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendering
        return mapView
    }()
    
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
        button.tintColor = .mapDarkBlackColor
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.setImage(.directionMapIcon, for: .normal)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 23,
                                                                      leading: 23,
                                                                      bottom: 23,
                                                                      trailing: 23)
        button.addTarget(self, action: #selector(direactionAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var locateMeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .mapDarkBlackColor
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.setImage(.locateMeMapIcon, for: .normal)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 23,
                                                                      leading: 23,
                                                                      bottom: 23,
                                                                      trailing: 23)
        button.addTarget(self, action: #selector(locateMeAction), for: .touchUpInside)
        button.accessibilityIdentifier = ViewsIdentifiers.General.locateMeButton
        return button
    }()
    
    private lazy var geofenceButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .mapDarkBlackColor
        button.backgroundColor = .white
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        button.layer.cornerRadius = 8
        button.setImage(.geofenceMapIcon, for: .normal)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 23,
                                                                      leading: 23,
                                                                      bottom: 23,
                                                                      trailing: 23)
        button.addTarget(self, action: #selector(openGeofence), for: .touchUpInside)
        return button
    }()
    
    private lazy var mapStyleButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityIdentifier = ViewsIdentifiers.General.mapStyles
        button.tintColor = .mapDarkBlackColor
        button.backgroundColor = .white
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.layer.cornerRadius = 8
        button.setImage(.mapStyleMapIcon, for: .normal)
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 23,
                                                                      leading: 23,
                                                                      bottom: 23,
                                                                      trailing: 23)
        button.addTarget(self, action: #selector(mapStyleAction), for: .touchUpInside)
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
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
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
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideGeoFence(state: Bool) {
        topStackView.isHidden = state
    }
    
    @objc func openGeofence() {
        self.geofenceButtonAction?()
    }
    
    func focusNavigationMode() {
        self.mapMode = .turnByTurnNavigation
        if let userCoordinates = mapView.userLocation?.coordinate,
           CLLocationCoordinate2DIsValid(userCoordinates) {
            mapView.setCenter(userCoordinates, zoomLevel: Constant.navigationMapZoonValue, direction: mapView.direction, animated: true) { [weak self] in
                self?.mapView.userTrackingMode = .followWithCourse
            }
        }
    }
    
    func focus(on coordinates: CLLocationCoordinate2D) {
        guard CLLocationCoordinate2DIsValid(coordinates) else { return }
        mapView.setCenter(coordinates, zoomLevel: Constant.mapZoomValue, direction: mapView.direction, animated: true)
    }
    
    func isLocateMeButtonDisabled(state: Bool) {
        locateMeButton.tintColor = state ? .maplightGrayColor : .mapDarkBlackColor
        
        guard !state,
              let userCoordinates = mapView.userLocation?.coordinate,
              CLLocationCoordinate2DIsValid(userCoordinates) else {
            mapView.setCenter(CLLocationCoordinate2D(latitude: Constant.amazonHqMapPosition.latitude, longitude: Constant.amazonHqMapPosition.longitude), zoomLevel: Constant.annotationMapZoomValue, animated: false)
            return
        }
        
        setMapCenter(userCoordinates: userCoordinates)
    }
    
    private func setMapCenter(userCoordinates: CLLocationCoordinate2D) {
        mapView.setCenter(userCoordinates, zoomLevel: Constant.navigationMapZoonValue, direction: mapView.direction, animated: true) { [weak self] in
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
        delegate?.showDirectionView(userLocation: mapView.userLocation?.coordinate)
    }
    
    func drawCalculatedRouteWith(_ data: Data, departureLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, isRecalculation: Bool, routeType: RouteTypes) {
        DispatchQueue.main.async {
            
            let isDashedLine: Bool
            switch routeType {
            case .walking:
                isDashedLine = true
            case .car, .truck:
                isDashedLine = false
            }
            
            self.drawPolyline(self.mapView, geoJson: data, isDashedLine: isDashedLine)
            
            let dashedData = self.mapMode == .search ? data : Data()
            self.drawDashedLine(self.mapView, geoJson: dashedData, departureCoordinates: departureLocation, destinationCoordinates: destinationLocation)
            
            guard !isRecalculation else { return }
            
            self.createAnnotationsForDirection(departureCoordinates: departureLocation, destinationCoordinates: destinationLocation)
            
            let coordinateBounds = MGLCoordinateBounds.create(from: [departureLocation, destinationLocation])
            let edgePadding = self.configureMapEdgePadding()
            
            self.mapView.setDirection(0, animated: false)
            self.mapView.setVisibleCoordinateBounds(coordinateBounds, edgePadding: edgePadding, animated: false, completionHandler: nil)
        }
    }
    
    private func configureMapEdgePadding() -> UIEdgeInsets {
        let staticInset: CGFloat = 80
        
        let topInset = staticInset + self.safeAreaInsets.top
        let leftInset = staticInset + self.safeAreaInsets.left
        // add small bottom padding on ipad
        let IPAD_INTENTIONAL_BOTTOM_PADDING = CGFloat(200) // Introduces bottom gutter/padding on iPad to assure modals don't overlap with the rendered route
        let bottomInset = (self.delegate?.getBottomSheetHeight() ?? 0) + (self.isiPad ? IPAD_INTENTIONAL_BOTTOM_PADDING : 0)
        let rightInset = staticInset + self.safeAreaInsets.right
        
        let edgePadding = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        
        return edgePadding
    }
    
    func shouldBottomStackViewPositionUpdate(state: Bool = false) {
        if state {
            bottomStackView.snp.remakeConstraints {
                $0.bottom.equalTo(searchBarView.snp.top).offset(-96)
                $0.trailing.equalToSuperview().offset(-16)
                $0.width.equalTo(48)
                $0.height.equalTo(104)
            }
        } else {
            bottomStackView.snp.remakeConstraints {
                $0.bottom.equalTo(searchBarView.snp.top).offset(-16)
                $0.trailing.equalToSuperview().offset(-16)
                $0.width.equalTo(48)
                $0.height.equalTo(104)
            }
        }
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
                self?.mapView?.setCenter(CLLocationCoordinate2D(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude), zoomLevel: Constant.singleAnnotationMapZoomValue, animated: false)
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
    
    func setupMapView() {
        let identityPoolId: String
        if let customModel = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) {
            identityPoolId = customModel.identityPoolId
        } else {
            identityPoolId = Bundle.main.object(forInfoDictionaryKey: Constant.dictinaryKeyIdentityPoolId) as! String
        }
        
        let regionName = identityPoolId.toRegionString()
        let mapName = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        
        let region = (regionName as NSString).aws_regionTypeValue()
        signingDelegate = AWSSignatureV4Delegate(region: region, identityPoolId: identityPoolId)
        // register a delegate that will handle SigV4 signing
        MGLOfflineStorage.shared.delegate = signingDelegate
        
        mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendering
        mapView.styleURL = URL(string: "https://maps.geo.\(regionName).amazonaws.com/maps/v0/maps/\(mapName?.imageType.mapName ?? "EsriLight")/style-descriptor")
        
        // it is just to force to redraw the mapView
        mapView.zoomLevel = mapView.zoomLevel + 0.01
        
        mapView.showsUserLocation = true
        locateMeAction(force: true)
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
        let newHeight = calculateMapHelperHeight()
        guard newHeight != currentMapHelperViewHeight else { return }
        
        mapHelperView.snp.removeConstraints()
        mapHelperView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(newHeight)
        }
        
        mapHelperView.setNeedsLayout()
        mapHelperView.layoutIfNeeded()
    }
    
    private func calculateMapHelperHeight() -> UInt {
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
        
        guard let screenHeight = window?.screen.bounds.height else { return 0 }
        return UInt(screenHeight) - topSafeArea - bottomOccupiedArea
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
    
    func drawPolyline(_ mapView: MGLMapView, geoJson: Data, isDashedLine: Bool) {
        // Add our GeoJSON data to the map as an MGLGeoJSONSource.
        // We can then reference this data from an MGLStyleLayer.
        
        // MGLMapView.style is optional, so you must guard against it not being set.
        guard let style = mapView.style else { return }
        
        if let layer =  style.layer(withIdentifier: "polyline") {
            style.removeLayer(layer)
        }
        
        if let layer2 = style.layer(withIdentifier: "polyline-case") {
            style.removeLayer(layer2)
        }
        
        if let layer3 = style.layer(withIdentifier: "trails-path") {
            style.removeLayer(layer3)
        }
        
        guard let shapeFromGeoJSON = try? MGLShape(data: geoJson,
                                                   encoding: String.Encoding.utf8.rawValue) else {
            fatalError("Could not generate MGLShape")
        }
        
        // create source and add it to the style
        let source = self.createSource(style, fromShape: shapeFromGeoJSON)
        
        // prepare layer parameters
        // Set the line join and cap to a rounded end.
        let lineJoinCap = NSExpression(forConstantValue: "round")
        // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 14 and 18.
        // The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
        let lineWidth = NSExpression(
            format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
            [16: 2, 20: 20])
        
        let lineColor = UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1)
        
        // create and add layers
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
    
    func drawDashedLine(_ mapView: MGLMapView, geoJson: Data, departureCoordinates: CLLocationCoordinate2D, destinationCoordinates: CLLocationCoordinate2D) {
        guard let style = mapView.style else { return }
        
        let shapeFromGeoJSON = (try? MGLShape(data: geoJson,
                                              encoding: String.Encoding.utf8.rawValue)) ?? MGLShape()
        
        drawDashedLine(style, shape: shapeFromGeoJSON, point: departureCoordinates, isFirst: true)
        drawDashedLine(style, shape: shapeFromGeoJSON, point: destinationCoordinates, isFirst: false)
    }
    
    func drawDashedLine(_ style: MGLStyle, shape: MGLShape, point: CLLocationCoordinate2D, isFirst: Bool) {
        let layerName = isFirst ? "dashed-layer-start-point" : "dashed-layer-end-point"
        let sourceName = isFirst ? "dashed-source-start-point" : "dashed-source-end-point"
        if let layer =  style.layer(withIdentifier: layerName) {
            style.removeLayer(layer)
        }
        if let source =  style.source(withIdentifier: sourceName) {
            style.removeSource(source)
        }
        
        guard let source = createDashedSource(shape: shape, point: point, isFirst: isFirst, identifier: sourceName) else { return }
        style.addSource(source)
        
        // prepare layer parameters
        // Set the line join and cap to a rounded end.
        let lineJoinCap = NSExpression(forConstantValue: "round")
        // Use `NSExpression` to smoothly adjust the line width from 2pt to 20pt between zoom levels 14 and 18.
        // The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
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
    
    func createDashedSource(shape: MGLShape, point firstPoint: CLLocationCoordinate2D, isFirst: Bool, identifier: String) -> MGLSource? {
        guard let secondPoint = findCoordinate(in: shape, isFirst: isFirst) else { return nil }
        
        let firstLocation = CLLocation(location: firstPoint)
        let secondLocation = CLLocation(location: secondPoint)
        
        let acceptableDifferenceInMeters: Double = 3
        guard firstLocation.distance(from: secondLocation) > acceptableDifferenceInMeters else { return nil }
        
        let polyline = MGLPolyline(coordinates: [firstPoint, secondPoint], count: 2)
        let source = MGLShapeSource(identifier: identifier, shape: polyline)
        
        return source
    }
    
    func findCoordinate(in shape: MGLShape, isFirst: Bool) -> CLLocationCoordinate2D? {
        if let polyline = shape as? MGLPolyline,
           polyline.pointCount > 0 {
            if isFirst {
                return polyline.coordinates[0]
            } else {
                return polyline.coordinates[Int(polyline.pointCount) - 1]
            }
        } else if let shapeCollection = shape as? MGLShapeCollectionFeature {
            for shape in shapeCollection.shapes {
                if let coordinate = findCoordinate(in: shape, isFirst: isFirst) {
                    return coordinate
                }
            }
        }
        return nil
    }
    
    func createSource(_ style: MGLStyle, fromShape shape: MGLShape) -> MGLSource {
        let source = MGLShapeSource(identifier: UUID().uuidString, shape: shape, options: nil)
        style.addSource(source)
        return source
    }
    
    func createLayer(_ source: MGLSource, withLineJoinCap lineJoinCap: NSExpression, withLineWidth lineWidth: NSExpression) -> MGLStyleLayer {
        // Create new layer for the line.
        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
        layer.lineJoin = lineJoinCap
        layer.lineCap = lineJoinCap
        // Set the line color to a constant blue color.
        layer.lineColor = NSExpression(forConstantValue: UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1))
        layer.lineWidth = lineWidth
        
        return layer
    }
    
    func createCasingLayer(_ source: MGLSource, withLineJoinCap lineJoinCap: NSExpression) -> MGLStyleLayer {
        // We can also add a second layer that will draw a stroke around the original line.
        let casingLayer = MGLLineStyleLayer(identifier: "polyline-case", source: source)
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
    
    func createDashLayer(_ source: MGLSource, withLineJoinCap lineJoinCap: NSExpression, withLineWidth lineWidth: NSExpression, color: UIColor = .white, identifier: String = "trails-path") -> MGLStyleLayer {
        let dashedLayer = MGLLineStyleLayer(identifier: identifier, source: source)
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
        
        containerView.addSubview(mapView)
        containerView.addSubview(topStackView)
        containerView.addSubview(bottomStackView)
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        searchBarView.snp.makeConstraints {
            $0.height.equalTo(76)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        amazonMapLogo.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.bottom.equalTo(searchBarView.snp.top).offset(-8)
            $0.height.equalTo(18)
            $0.width.equalTo(121)
        }
        
        infoButton.snp.makeConstraints {
            $0.height.width.equalTo(13.5)
            $0.leading.equalTo(amazonMapLogo.snp.trailing).offset(5)
            $0.centerY.equalTo(amazonMapLogo.snp.centerY)
        }
        
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        geofenceButton.snp.makeConstraints {
            $0.height.width.equalTo(48)
        }
        
        dividerView.snp.makeConstraints {
            $0.height.width.equalTo(1)
        }
        
        mapStyleButton.snp.makeConstraints {
            $0.height.width.equalTo(48)
        }
        
        topStackView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(48)
            $0.height.equalTo(100)
        }
        
        directonButton.snp.makeConstraints {
            $0.height.width.equalTo(48)
        }
        
        locateMeButton.snp.makeConstraints {
            $0.height.width.equalTo(48)
        }
        
        bottomStackView.snp.makeConstraints {
            $0.bottom.equalTo(searchBarView.snp.top).offset(-16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(48)
            $0.height.equalTo(104)
        }
        
        updateMapHelperConstraints()
    }
}

private extension ExploreView {
    @objc func locateMeAction(force: Bool = false) {
        let action = { [weak self] in
            guard let self else { return }
            let state = self.mapView.locationManager.authorizationStatus == .authorizedWhenInUse
            self.isLocateMeButtonDisabled(state: !state)
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

extension ExploreView: MGLMapViewDelegate {
    
    
    // in the difference of standard approach if we are in live navigation mode we always return to
    // current location and zoom mode.
    func mapView(_ mapView: MGLMapView, regionDidChangeWith reason: MGLCameraChangeReason, animated: Bool) {
        switch reason {
        case .gesturePan, .gesturePinch, .gestureRotate, .gestureZoomIn, .gestureZoomOut, .gestureTilt:
            if mapMode == .turnByTurnNavigation {
                if let userCoordinates = mapView.userLocation?.coordinate,
                   CLLocationCoordinate2DIsValid(userCoordinates) {
                    mapView.setCenter(userCoordinates, zoomLevel: Constant.navigationMapZoonValue, direction: mapView.direction, animated: true) { [weak self] in
                        self?.mapView.userTrackingMode = .followWithCourse
                    }
                }
            }
        default:
            break
        }
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        guard mapMode == .search else { return }
        showCard(annotation: annotation, mapView: mapView)
    }
    
    private func showCard(annotation: MGLAnnotation, mapView: MGLMapView? = nil) {
        let cardData = searchDatas.filter {$0.placeLong == annotation.coordinate.longitude && $0.placeLat == annotation.coordinate.latitude}
        
        if let zoomData = cardData[safe: 0], let lat = zoomData.placeLat, let long = zoomData.placeLong {
            mapView?.setCenter(CLLocationCoordinate2D(latitude: lat, longitude: long), zoomLevel: Constant.singleAnnotationMapZoomValue, animated: false)
        }
        
        
        delegate?.showPoiCard(cardData: cardData)
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        switch annotation {
        case is MGLUserLocation:
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constant.userLocationViewIdentifier) {
                annotationView.annotation = annotation
                return annotationView
            } else {
                return LSFaux3DUserLocationAnnotationView(annotation: annotation, reuseIdentifier: Constant.userLocationViewIdentifier)
            }
        case is ImageAnnotation:
            guard let imageAnnotation = annotation as? ImageAnnotation else { return nil }
            let imageAnnotationView: MGLAnnotationView
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constant.imageAnnotationViewIdentifier) as? ImageAnnotationView {
                annotationView.annotation = imageAnnotation
                annotationView.addImage(imageAnnotation.image)
                
                imageAnnotationView = annotationView
            } else {
                imageAnnotationView = ImageAnnotationView(annotation: imageAnnotation, reuseIdentifier: Constant.imageAnnotationViewIdentifier)
            }
            
            imageAnnotationView.accessibilityIdentifier = ViewsIdentifiers.General.imageAnnotationView
            return imageAnnotationView
        default:
            return nil
        }
    }
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        switch mapMode {
        case .search:
            guard !wasCenteredByUserLocation,
                  let userCoordinates = userLocation?.coordinate else { return }
            
            wasCenteredByUserLocation = true
            setMapCenter(userCoordinates: userCoordinates)
        case .turnByTurnNavigation:
            guard let userCoordinates = userLocation?.coordinate else { return }
            delegate?.userLocationChanged(userCoordinates)
        }
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MGLMapView) {
        mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendering
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MGLMapView, fullyRendered: Bool) {
        if fullyRendered {
            debounceForMapRendering.debounce { [weak self] in
                self?.updateMapHelperConstraints()
                self?.mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendered
            }
        } else {
            debounceForMapRendering.debounce {}
            mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendering
        }
    }
    
    func mapViewWillStartRenderingFrame(_ mapView: MGLMapView) {
        mapView.accessibilityIdentifier = ViewsIdentifiers.General.mapRendering
    }
    
    //frame callback called multiple times even before all map layers are rendered. The fullRendered propery also isn't reliable as it sends true state before map fully rendered. Based on this debounce manager is used here to overcome these issues.
    func mapViewDidFinishRenderingFrame(_ mapView: MGLMapView, fullyRendered: Bool) {
        if fullyRendered {
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
    
    func accountButtonTapped() {
        delegate?.loginButtonTapped()
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
