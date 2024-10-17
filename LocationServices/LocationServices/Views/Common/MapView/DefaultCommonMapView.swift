//
//  DefaultCommonMapView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import MapLibre


private enum Constant {
    static let mapZoomValue: Double = 20
    static let singleAnnotationMapZoomValue: Double = 17
    static let directionMapZoomValue: Double = 14
    static let annotationMapZoomValue: Double = 10
    static let locateMeMapZoomValue: Double = 14
    static let amazonHqMapPosition = (latitude: 47.61506909519956, longitude: -122.33826750882835)
    static let geofenceViewIdentifier = "GeofenceViewIdentifier"
    static let userLocationViewIdentifier = "UserLocationViewIdentifier"
    static let imageAnnotationViewIdentifier = "ImageAnnotationViewIdentifier"
    static let mainBundleNameObject = "AWSRegion"
    static let dictionaryKeyIdentityPoolId = "IdentityPoolId"
}

final class DefaultCommonMapView: UIView, NavigationMapProtocol {
    
    weak var delegate: BottomSheetPresentable?
    private var geofenceAnnotation: [MLNAnnotation] = []
    var isDrawCirle = false
    var enableGeofenceDrag = false
    var geofenceAnnotationRadius: Int64 = 80
    private var isiPad = UIDevice.current.userInterfaceIdiom == .pad
    
    private(set) var mapMode: MapMode = .search
    private(set) var userLocation: CLLocation?
    private(set) var userHeading: CLHeading?
    private var wasCenteredByUserLocation = false
    private var searchDatas: [MapModel] = []
    
    private var isGeofenceAnnotation: Bool = false
    
    var selectedAnnotationCallback: ((MLNAnnotation)->())?
    
    var mapView: MLNMapView = {
        let mapView = MLNMapView()
        mapView.tintColor = .lsPrimary
        mapView.compassView.isHidden = true
        mapView.zoomLevel = 12
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.showsUserHeadingIndicator = false
        
        return mapView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        mapView.delegate = self
        setupMapView()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        self.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setupMapView() {
        DispatchQueue.main.async { [self] in
            mapView.styleURL = DefaultMapStyles.getMapStyleUrl()
            // it is just to force to redraw the mapView
            mapView.zoomLevel = mapView.zoomLevel + 0.01
            
            locateMeAction()
            mapView.showsUserLocation = true
        }
    }
    
    func isLocateMeButtonDisabled(state: Bool) {
        
        guard !state,
              let userCoordinates = mapView.userLocation?.coordinate,
              CLLocationCoordinate2DIsValid(userCoordinates) else {
            mapView.setCenter(CLLocationCoordinate2D(latitude: Constant.amazonHqMapPosition.latitude, longitude: Constant.amazonHqMapPosition.longitude), zoomLevel: Constant.annotationMapZoomValue, animated: false)
            return
        }
        
        setMapCenter(userCoordinates: userCoordinates)
    }
    
    func grantedLocationPermissions() {
        self.mapView.showsUserLocation = true
    }
    
    func getUserLocation() -> CLLocationCoordinate2D? {
        return mapView.userLocation?.coordinate
    }
    
    func setupTapGesture(_ mapTapGestureRecognizer: UITapGestureRecognizer) {
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            mapTapGestureRecognizer.require(toFail: recognizer)
        }
        mapView.addGestureRecognizer(mapTapGestureRecognizer)
    }
    
    func update(userLocation: CLLocation?, userHeading: CLHeading?) {
        self.userLocation = userLocation
        self.userHeading = userHeading
        mapView.updateUserLocationAnnotationView()
    }
}

extension DefaultCommonMapView: MLNMapViewDelegate {
    func mapView(_ mapView: MLNMapView, didSelect annotation: MLNAnnotation) {
        selectedAnnotationCallback?(annotation)
    }
    
    func mapView(_ mapView: MLNMapView, viewFor annotation: MLNAnnotation) -> MLNAnnotationView? {
        switch annotation {
        case is GeofenceAnnotation:
            let identifier = "\(Constant.geofenceViewIdentifier)+\(annotation.coordinate.hashValue)"
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationView.annotation = annotation
                (annotationView as! GeofenceAnnotationView).enableGeofenceDrag = enableGeofenceDrag
                return annotationView
            } else {
                let annotationView = GeofenceAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.enableGeofenceDrag = enableGeofenceDrag
                return annotationView
            }
        case is MLNUserLocation:
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constant.userLocationViewIdentifier) {
                annotationView.annotation = annotation
                return annotationView
            } else {
                return LSFaux3DUserLocationAnnotationView(annotation: annotation, reuseIdentifier: Constant.userLocationViewIdentifier)
            }
        case is ImageAnnotation:
            guard let imageAnnotation = annotation as? ImageAnnotation else { return nil }
            let imageAnnotationView: MLNAnnotationView
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
    
    func mapView(_ mapView: MLNMapView, didUpdate userLocation: MLNUserLocation?) {
        switch mapMode {
        case .search:
            guard !wasCenteredByUserLocation,
                  let userCoordinates = userLocation?.coordinate else { return }
            
            wasCenteredByUserLocation = true
            setMapCenter(userCoordinates: userCoordinates)
        case .turnByTurnNavigation:
            guard (userLocation?.coordinate) != nil else { return }
        }
    }
    
    func mapView(_ mapView: MLNMapView, didAdd annotationViews: [MLNAnnotationView]) {
        annotationViews.forEach({
            ($0 as? GeofenceAnnotationView)?.update(mapView: mapView)
        })
    }
    
    func mapViewRegionIsChanging(_ mapView: MLNMapView) {
        updateVisibleGeofenceAnnotations(on: mapView)
    }
    
    func mapView(_ mapView: MLNMapView, regionDidChangeAnimated animated: Bool) {
        updateVisibleGeofenceAnnotations(on: mapView)
    }
    
    func updateVisibleGeofenceAnnotations(on mapView: MLNMapView) {
        mapView.visibleAnnotations?.forEach({
            guard let geofenceAnnotationView = mapView.view(for: $0) as? GeofenceAnnotationView else { return }

            geofenceAnnotationView.update(mapView: mapView)
        })
    }
}

extension DefaultCommonMapView {
    @objc func locateMeAction() {
        let state = mapView.locationManager.authorizationStatus == .authorizedWhenInUse
        isLocateMeButtonDisabled(state: !state)
    }
    
    private func setMapCenter(userCoordinates: CLLocationCoordinate2D) {
        mapView.setCenter(userCoordinates, zoomLevel: Constant.locateMeMapZoomValue, direction: mapView.direction, animated: true) { [weak self] in
            switch self?.mapMode {
            case .search, .none:
                self?.mapView.userTrackingMode = .follow
            case .turnByTurnNavigation:
                self?.mapView.userTrackingMode = .followWithCourse
            }
        }
    }
}

extension DefaultCommonMapView {
    func deselectAnnotation() {
    }
    
    func showPlacesOnMapWith(_ mapModel: [MapModel], isGeofenceItem: Bool) {
        isGeofenceAnnotation = isGeofenceItem
        self.mapView.annotations?.forEach({ data in
            self.mapView.removeAnnotation(data)
        })
        
        let annotationImage: UIImage
        if mapModel.count == 1 {
            annotationImage = .selectedPlace
        } else if isGeofenceAnnotation {
            annotationImage = .geofenceDashoard
        } else {
            annotationImage = .annotationIcon
        }
        
        var points = [ImageAnnotation]()
        mapModel.forEach { model in
            if let lat = model.placeLat, let long = model.placeLong {
                let coordinates = CLLocationCoordinate2D(latitude: long, longitude: lat)
                let point = ImageAnnotation(image: annotationImage)
                point.coordinate = coordinates
                point.title = model.placeName
                points.append(point)
            }
        }
        mapView.addAnnotations(points)
        if points.count > 1 {
            self.mapView.showAnnotations(points, animated: false)
        } else if let point = points.first {
            self.mapView.setCenter(CLLocationCoordinate2D(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude), zoomLevel: 17, animated: false)
        }
    }
}

// Geofence Circle Methods

extension DefaultCommonMapView  {
    func drawGeofenceCircle(id: String?, latitude: Double?, longitude: Double?, radius: Double, title: String?) {
        guard let latitude,
              let longitude else { return }
        self.mapView.annotations?.forEach({ data in
            self.mapView.removeAnnotation(data)
        })
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let coordinateBounds = MLNCoordinateBounds.create(centerLocation: coordinates, radius: Double(radius))
        let edgePadding = configureMapEdgePadding()
        self.mapView.setVisibleCoordinateBounds(coordinateBounds, edgePadding: edgePadding, animated: false, completionHandler: nil)
        
        let geofenceAnnotation = GeofenceAnnotation(id: id, radius: Double(radius), title: title, coordinate: coordinates)
        mapView.addAnnotation(geofenceAnnotation)
    }
    
    private func configureMapEdgePadding() -> UIEdgeInsets {
        let staticInset: CGFloat = 0
        
        let topInset = staticInset + self.safeAreaInsets.top
        let leftInset = staticInset + self.safeAreaInsets.left
        // add small bottom padding on ipad
        let IPAD_INTENTIONAL_BOTTOM_PADDING = CGFloat(200) // Introduces bottom gutter/padding on iPad to assure modals don't overlap with the rendered route
        let bottomInset = (self.delegate?.getBottomSheetHeight() ?? 0) + (self.isiPad ? IPAD_INTENTIONAL_BOTTOM_PADDING : 0)
        let rightInset = staticInset + self.safeAreaInsets.right
        
        let edgePadding = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        
        return edgePadding
    }
    
    func deleteGeofence(latitude: Double?, longitude: Double?) {
        self.mapView.annotations?.forEach({ data in
            if data.coordinate.latitude == latitude, data.coordinate.longitude == longitude {
                self.mapView.removeAnnotation(data)
            }
        })
    }
}

extension DefaultCommonMapView {
    func draw(layer: MLNStyleLayer, source: MLNSource) {
        guard let style = mapView.style else { return }
        if let oldLayer = style.layer(withIdentifier: layer.identifier) {
            style.removeLayer(oldLayer)
        }
        if let source = style.source(withIdentifier: source.identifier) {
            style.removeSource(source)
        }
        
        style.addSource(source)
        
        if let symbolLayer = style.layers.last {
            style.insertLayer(layer, below: symbolLayer)
        } else {
            style.addLayer(layer)
        }
    }
    
    func removeLayer(with identifier: String) {
        guard let style = mapView.style,
              let layer = style.layer(withIdentifier: identifier) else { return }
        style.removeLayer(layer)
    }
    
    func remove(annotations: [MLNAnnotation]) {
        mapView.removeAnnotations(annotations)
    }
    
    func addAnnotations(annotations: [MLNAnnotation]) {
        mapView.addAnnotations(annotations)
    }
    
    func removeAllAnnotations() {
        self.mapView.annotations?.forEach({ data in
            self.mapView.removeAnnotation(data)
        })
    }
}
