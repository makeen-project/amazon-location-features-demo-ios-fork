//
//  GeofenceView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import Mapbox

protocol GeofenceMapViewDelegate {
    var delegate: GeofenceMapViewOutputDelegate { get set }
}

protocol GeofenceMapViewOutputDelegate: BottomSheetPresentable {
    func geofenceButtonAction()
    func showMapLayers()
    func directionHandlers()
    func selectedAnnotation(_ annotation: MGLAnnotation)
    func showAttribution()
    func showAddGeofence(lat: Double?, long: Double?)
}

final class GeofenceMapView: UIView {
    var delegate: GeofenceMapViewOutputDelegate? {
        didSet {
            mapView.delegate = delegate
        }
    }
    
    private var mapView: DefaultCommonMapView = DefaultCommonMapView()
    private var mapLayer: MapOverlayItems = MapOverlayItems()
    
    private let searchBarView: SearchBarView = SearchBarView()
    
    private var geofenceAnnotations: [GeofenceAnnotation] = []
    
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
   
        searchBarView.isUserInteractionEnabled = false
        mapLayer.delegate = self
        searchBarView.delegate = self
        mapView.delegate = delegate
        setupViews()
        
        mapView.selectedAnnotationCallback = { [weak self] annotation in
            self?.delegate?.selectedAnnotation(annotation)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupViews() {
        self.addSubview(mapView)
        self.addSubview(searchBarView)
        self.addSubview(amazonMapLogo)
        self.addSubview(infoButton)
        self.addSubview(mapLayer)
       
        mapView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
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
        
        mapLayer.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.bottom.equalTo(searchBarView.snp.top).offset(-16)
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
        deselectAnnotation()
    }
    
    func deselectAnnotation() {
        mapView.deselectAnnotation()
    }
    
    func drawGeofenceCirle(id: String?, lat: Double?, long: Double?, radius: Int64, title: String?) {
        mapView.drawGeofenceCircle(id: id, latitude: lat, longitude: long, radius: radius, title: title)
    }
    
    func deleteGeofenceData(lat: Double?, long: Double?) {
        mapView.deleteGeofence(latitude: lat, longitude: long)
    }
    
    func deleteGeofenceData(with id: String) {
        geofenceAnnotations.removeAll(where: { $0.id == id })
        mapView.removeAllAnnotations()
        mapView.addAnnotations(annotations: geofenceAnnotations)
    }
    
    func addGeofenceData(_ model: GeofenceDataModel) {
        if let annotation = createGeofenceAnnotation(model: model, isSelected: false) {
            if let existedIndex = geofenceAnnotations.firstIndex(where: { $0.id == model.id }) {
                geofenceAnnotations.remove(at: existedIndex)
            }
            geofenceAnnotations.insert(annotation, at: 0)
        }
        
        mapView.removeAllAnnotations()
        mapView.addAnnotations(annotations: geofenceAnnotations)
    }
    
    func hideSearchView() {
        searchBarView.isHidden = true
    }
    
    func updateMapLayerPosition(value: Int) {
        mapLayer.snp.removeConstraints()
        
        mapLayer.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.bottom.equalTo(searchBarView.snp.top).offset(-value)
            $0.width.equalTo(50)
        }
    }
    
    func removeAllAnnotations() {
        mapView.removeAllAnnotations()
    }
    
    func showExistedGeofences() {
        removeAllAnnotations()
        mapView.addAnnotations(annotations: geofenceAnnotations)
    }
    
    func showGeofenceAnnotations(_ models: [GeofenceDataModel]) {
        mapView.remove(annotations: geofenceAnnotations)
        
        geofenceAnnotations = models.compactMap { model -> GeofenceAnnotation? in
            return createGeofenceAnnotation(model: model, isSelected: false)
        }
        mapView.addAnnotations(annotations: geofenceAnnotations)
    }
    
    private func createGeofenceAnnotation(model: GeofenceDataModel, isSelected: Bool) -> GeofenceAnnotation? {
        guard let lat = model.lat,
              let long = model.long else { return nil }
        
        let radius = isSelected ? model.radius : 0
        guard let radius else { return nil }
        
        let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        return GeofenceAnnotation(id: model.id, radius: Double(radius), title: model.name, coordinate: coordinates)
    }
    
    @objc private func infoButtonAction() {
        delegate?.showAttribution()
    }
    
    func setupTapGesture() {
        let mapTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapViewTapped))
        mapView.setupTapGesture(mapTapGestureRecognizer)
    }
    
    @objc func mapViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let mapView = self.mapView.mapView
        let tapPoint = gestureRecognizer.location(in: mapView)
        let location = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        delegate?.showAddGeofence(lat: location.latitude, long: location.longitude)
    }
    
    func update(userLocation: CLLocation?, userHeading: CLHeading?) {
        mapView.update(userLocation: userLocation, userHeading: userHeading)
    }
}

extension GeofenceMapView: MapOverlayItemsOutputDelegate {
    func mapLayerButtonAction() {
        delegate?.showMapLayers()
    }
    
    func directionButtonAction() {
        delegate?.directionHandlers()
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

extension GeofenceMapView: SearchBarViewOutputDelegate {
    
    func searchTextActivated() {
        // TODO: Will be implemented later
    }
    
    func searchTextDeactivated() {
        // TODO: Will be implemented later
    }
    
    func accountButtonTapped() {
        // TODO: Will be implemented later
    }
}
