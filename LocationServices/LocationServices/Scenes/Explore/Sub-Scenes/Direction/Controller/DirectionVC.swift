//
//  DirectionVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import CoreLocation

final class DirectionVC: UIViewController {
    
    enum Constants {
        static let mediumId = UISheetPresentationController.Detent.Identifier("medium")
    }
    
    var dismissHandler: VoidHandler?
    var isRoutingOptionsEnabled: Bool = false
    var firstDestionation: DirectionTextFieldModel?
    var secondDestionation: DirectionTextFieldModel?
    var isInitalState: Bool = true
    var userLocation: (lat: Double?, long: Double?)? {
        didSet {
            guard let lat = userLocation?.lat,
                  let long = userLocation?.long else {
                return
            }
            
            let userLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            guard !CLLocationCoordinate2DIsValid(userLocation) else { return }
            self.userLocation = nil
        }
    }
    private lazy var locationManager: LocationManager = {
        let locationManager = LocationManager(alertPresenter: self)
        locationManager.setDelegate(self)
        return locationManager
    }()
    
    var isDestination: Bool = true
    var deleteScreenDrawing: Bool = true
    
    var viewModel: DirectionViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    var directionSearchView: DirectionSearchView = DirectionSearchView()
    
    lazy var directionView: DirectionView = DirectionView()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .searchBarBackgroundColor
        tableView.keyboardDismissMode = .interactive
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.userLocation = userLocation
        viewModel.addMyLocationItem()
        directionView.delegate = self
        directionSearchView.delegate = self
        view.backgroundColor = .searchBarBackgroundColor
        setupHandlers()
        setupTableView()
        setupViews()
        viewModel.loadLocalOptions()
        
        if firstDestionation?.placeName == "My Location" {
            directionSearchView.setMyLocationText()
        }
        locationManagerSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotifications()
        if deleteScreenDrawing {
            self.dismissHandler?()
        }
    }
    
    private func locationManagerSetup() {
        locationManager.performLocationDependentAction {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    private func setupHandlers() {
      
        
        directionSearchView.searchTextHandler = { [weak self] model in
            // Delete my location value and restore My location text
            if model.searchText == "" {
                if model.isDestination {
                    self?.secondDestionation = DirectionTextFieldModel(placeName: "",
                                                                      placeAddress: nil,
                                                                      lat: nil, long: nil)
                } else {
                    self?.firstDestionation = DirectionTextFieldModel(placeName: "",
                                                                      placeAddress: nil,
                                                                      lat: nil, long: nil)
                }
                
                if self?.firstDestionation?.placeName != "My Location"  && self?.secondDestionation?.placeName != "My Location" {
                    self?.viewModel.addMyLocationItem()
                }
            }
            
            self?.isDestination = model.isDestination
            self?.directionView.isHidden = true
            self?.tableView.isHidden = false
            self?.viewModel.searchWithSuggesstion(text: model.searchText,
                                                  userLat: self?.userLocation?.lat,
                                                  userLong: self?.userLocation?.long)
        }
        
        directionSearchView.searchReturnHandler = { [weak self] model in
            self?.isDestination = model.isDestination
            self?.directionView.isHidden = true
            self?.tableView.isHidden = false
            self?.viewModel.searchWith(text: model.searchText,
                                       userLat: self?.userLocation?.lat,
                                       userLong: self?.userLocation?.long)
        }
        
        directionView.avoidTolls = { [weak self] state in
            let travelModel = self?.viewModel.selectedTravelMode
            let avoidFerries = self?.viewModel.avoidFerries
            self?.calculateRoute(routeType: travelModel ?? .car,
                                 avoidTolls: state,
                                 avoidFerries: avoidFerries ?? false)
        }
        
        directionView.avoidFerries = { [weak self] state in
            let travelModel = self?.viewModel.selectedTravelMode
            let avoidToll = self?.viewModel.avoidTolls
            self?.calculateRoute(routeType: travelModel ?? .car,
                                 avoidTolls: avoidToll ?? false,
                                 avoidFerries: state)
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(grantedLocationPermissions(_:)), name: Notification.grantedLocationPermissions, object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.grantedLocationPermissions, object: nil)
    }
    
    @objc private func grantedLocationPermissions(_ notification: Notification) {
        guard let userLocation = notification.userInfo?["userLocation"] as? CLLocation else {
            return
        }
        
        self.userLocation = (userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        
        let currentLocation = DirectionTextFieldModel(placeName: "My Location", placeAddress: nil, lat: self.userLocation?.lat, long: self.userLocation?.long)
        
        if firstDestionation?.placeName == "My Location" {
            firstDestionation = currentLocation
        } else if secondDestionation?.placeName == "My Location" {
            secondDestionation = currentLocation
        }
        
        calculateRoute()
    }
    
    private func setupViews() {
        directionSearchView.changeSearchRouteName(with: firstDestionation?.placeName, isDestination: false)
        directionSearchView.changeSearchRouteName(with: secondDestionation?.placeName, isDestination: true)
        self.view.addSubview(directionSearchView)
        self.view.addSubview(directionView)
        self.view.addSubview(tableView)
        
        directionSearchView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().offset(14)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(140)
        }
        
        directionView.snp.makeConstraints {
            $0.top.equalTo(directionSearchView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(560)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(directionSearchView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        directionView.isHidden = true
        if isRoutingOptionsEnabled  {
            tableView.isHidden = true
            sheetPresentationController?.selectedDetentIdentifier = Constants.mediumId
            calculateRoute()
        } else {
            tableView.isHidden = false
            
            let isDestination = firstDestionation?.placeName != nil
            directionSearchView.becomeFirstResponder(isDestination: isDestination)
        }
    }
    
    private func calculateRoute(routeType: RouteTypes = .car,
                                avoidTolls: Bool = false,
                                avoidFerries: Bool = false) {
        directionSearchView.closeKeyboard()
        self.sheetPresentationController?.selectedDetentIdentifier = Constants.mediumId
        
        updateMyLocationDestination()
        
        let currentModel = SearchCellViewModel(searchType: .location,
                                               placeId: nil,
                                               locationName: secondDestionation?.placeName,
                                               locationDistance: nil,
                                               locationCountry: nil,
                                               locationCity: nil,
                                               label: nil,
                                               long: secondDestionation?.long,
                                               lat: secondDestionation?.lat)
        calculateGenericRoute(currentModel: currentModel,
                              routeType: routeType,
                              avoidFerries: avoidFerries,
                              avoidTolls: avoidTolls)
    }
    
    func setupSearchTitleDestinations() {
        self.directionSearchView.changeSearchRouteName(with: firstDestionation?.placeName ?? "", isDestination: false)
        self.directionSearchView.changeSearchRouteName(with: secondDestionation?.placeName ?? "", isDestination: true)
    }
    
    func calculateGenericRoute(currentModel: SearchCellViewModel, routeType: RouteTypes = .car, avoidFerries: Bool = false, avoidTolls: Bool = false) {
        
        guard let (departureLocation, destinationLocation) = getRouteLocations(currentModel: currentModel) else { return }
        
        guard isDistanceValid(departureLoc: departureLocation, destinationLoc: destinationLocation) else { return }
        viewModel.calculateRouteWith(destinationPosition: destinationLocation,
                                     departurePosition: departureLocation,
                                     travelMode: routeType,
                                     avoidFerries: avoidFerries,
                                     avoidTolls: avoidTolls) { data,model  in
            self.tableView.isHidden = true
            self.directionView.isHidden = false
            
            let isPreview = self.firstDestionation?.placeName != "My Location"
            self.directionView.setup(model: model, isPreview: isPreview)
            DispatchQueue.main.async {
                self.directionView.showOptionsStackView()
            }
            
            self.setupSearchTitleDestinations()
            self.view.endEditing(true)
            self.sendDirectionsToExploreVC(data: data,
                                           departureLocation: departureLocation,
                                           destinationLocation: destinationLocation,
                                           routeType: routeType)
        }
    }
    
    private func updateMyLocationDestination() {
        if firstDestionation?.placeName == "My Location" {
            firstDestionation?.lat = userLocation?.lat
            firstDestionation?.long = userLocation?.long
        } else if secondDestionation?.placeName == "My Location" {
            secondDestionation?.lat = userLocation?.lat
            secondDestionation?.long = userLocation?.long
        }
    }
    
    private func getRouteLocations(currentModel: SearchCellViewModel) -> (departure: CLLocationCoordinate2D, destination: CLLocationCoordinate2D)? {
        updateMyLocationDestination()
        if let departureLat = firstDestionation?.lat,
           let departureLong = firstDestionation?.long,
           let destionationLat = secondDestionation?.lat,
           let destinationLong = secondDestionation?.long {
            
            let departureLoc = CLLocationCoordinate2D(latitude: departureLat, longitude: departureLong)
            let destionationLoc = CLLocationCoordinate2D(latitude: destionationLat, longitude: destinationLong)
            
            return (departureLoc, destionationLoc)
        } else {
            guard let userLat = userLocation?.long,
                  let userlong = userLocation?.lat,
                  let destionationLat = currentModel.lat,
                  let destinationLong = currentModel.long else {
                return nil
            }
            let userLoc = CLLocationCoordinate2D(latitude: userLat, longitude: userlong)
            let secondDestination = CLLocationCoordinate2D(latitude: destionationLat, longitude: destinationLong)
            
            let isStartFromCurrentLocation = firstDestionation?.placeName == "My Location"
            let isEndWithCurrentLocation = secondDestionation?.placeName == "My Location"
            
            if isStartFromCurrentLocation {
                return (userLoc, secondDestination)
            } else if isEndWithCurrentLocation {
                return (secondDestination, userLoc)
            } else {
                return nil
            }
        }
    }
    
    func calculateRoute()  {
        updateMyLocationDestination()
        
        if let departureLat = firstDestionation?.lat, let departureLong = firstDestionation?.long, let destionationLat = secondDestionation?.lat, let destinationLong = secondDestionation?.long {
            
            let departureLoc = CLLocationCoordinate2D(latitude: departureLat, longitude: departureLong)
            let destionationLoc = CLLocationCoordinate2D(latitude: destionationLat, longitude: destinationLong)
            
            guard isDistanceValid(departureLoc: departureLoc, destinationLoc: destionationLoc) else { return }
            viewModel.calculateRouteWith(destinationPosition: destionationLoc, departurePosition: departureLoc, avoidFerries: viewModel.avoidFerries, avoidTolls: viewModel.avoidTolls) { data,model  in
                
                self.tableView.isHidden = true
                self.directionView.isHidden = false
                DispatchQueue.main.async {
                    self.directionView.showOptionsStackView()
                }
                
                let isPreview = self.firstDestionation?.placeName != "My Location"
                self.directionView.setup(model: model, isPreview: isPreview)
                
                self.sendDirectionsToExploreVC(data: data,
                                               departureLocation: departureLoc,
                                               destinationLocation: destionationLoc, routeType: .car)
            }
        }
    }
    
    private func getRouteModel(for type: RouteTypes) -> RouteModel? {
        updateMyLocationDestination()
        
        let departureLat = firstDestionation?.lat
        let departureLong = firstDestionation?.long
        let departurePlaceName = firstDestionation?.placeName
        let departurePlaceAddress = firstDestionation?.placeAddress
        
        let destinationLat = secondDestionation?.lat
        let destinationLong = secondDestionation?.long
        let destinationPlaceName = secondDestionation?.placeName
        let destinationPlaceAddress = secondDestionation?.placeAddress
        
        guard let departureLat,
              let departureLong,
              let destinationLat,
              let destinationLong else {
            return nil
        }
        
        let departureLoc = CLLocationCoordinate2D(latitude: departureLat, longitude: departureLong)
        let destionationLoc = CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLong)
        
        let avoidFerries = viewModel.avoidFerries
        let avoidToll = viewModel.avoidTolls
        
        let isPreview = departurePlaceName != "My Location"
        
        let routeModel = RouteModel(departurePosition: departureLoc, destinationPosition: destionationLoc, travelMode: type, avoidFerries: avoidFerries, avoidTolls: avoidToll, isPreview: isPreview, departurePlaceName: departurePlaceName, departurePlaceAddress: departurePlaceAddress, destinationPlaceName: destinationPlaceName, destinationPlaceAddress: destinationPlaceAddress)
        
        return routeModel
    }
    
    private func isDistanceValid(departureLoc: CLLocationCoordinate2D, destinationLoc: CLLocationCoordinate2D) -> Bool {
        let currentMapStyle = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        switch currentMapStyle?.type {
        case .esri, .none:
            let userLocation = CLLocation(location: departureLoc)
            let placeLocation = CLLocation(location: destinationLoc)
            
            let distance = userLocation.distance(from: placeLocation)
            guard distance < NumberConstants.fourHundredKMInMeters else {
                DispatchQueue.main.async {
                    self.directionView.showErrorStackView()
                    self.tableView.isHidden = true
                    self.directionView.isHidden = false
                }
                return false
            }
        case .here:
            break
        }
        return true
    }
}

extension DirectionVC: DirectionViewModelOutputDelegate {
    func getLocalRouteOptions(tollOption: Bool, ferriesOption: Bool) {
        directionView.setLocalValues(toll: tollOption, ferries: ferriesOption)
    }
    
    func selectedPlaceResult(mapModel: [MapModel]) {
        
        if let model = mapModel[safe: 0] {
            let currentModel = SearchCellViewModel(searchType: .location,
                                                   placeId: nil,
                                                   locationName: model.placeName,
                                                   locationDistance: nil,
                                                   locationCountry: nil,
                                                   locationCity: nil,
                                                   label: model.placeName,
                                                   long: model.placeLong,
                                                   lat: model.placeLat)
            
            let searchTextModel = DirectionTextFieldModel(placeName: currentModel.locationName ?? "", placeAddress: model.placeAddress, lat: currentModel.lat, long: currentModel.long)
            
            if self.isDestination  {
                secondDestionation = searchTextModel
            } else {
                firstDestionation = searchTextModel
            }
            calculateGenericRoute(currentModel: currentModel, avoidFerries: viewModel.avoidFerries, avoidTolls: viewModel.avoidTolls)
            DispatchQueue.main.async {
                self.sheetPresentationController?.selectedDetentIdentifier = Constants.mediumId
            }
        }
    }
    
    func searchResult(mapModel: [MapModel]) {
        isInitalState = false
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func reloadView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func selectedDirection() {
        
    }
    
    func isMyLocationAlreadySelected() -> Bool {
        return [firstDestionation, secondDestionation].contains(where: { $0?.placeName == "My Location" })
    }
}

extension DirectionVC: DirectionViewOutputDelegate {
    func startNavigation(type: RouteTypes) {
        let navigationLegs = self.viewModel.getCurrentNavigationLegsWith(type)
        
        switch navigationLegs {
        case .success(let steps):
            self.deleteScreenDrawing = false
            let routeModel = self.getRouteModel(for: type)
            let sumData = self.viewModel.getSumData(type)
            
            if self.viewModel.selectedTravelMode != type {
                self.changeRoute(type: type)
            }
            
            let userInfo = ["steps" : (steps: steps, sumData: sumData), "routeModel": routeModel as Any] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name("NavigationSteps"), object: nil, userInfo: userInfo)
        case .failure(let error):
            let alertModel = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
            self.showAlert(alertModel)
        }
    }
    
    func changeRoute(type: RouteTypes) {
        calculateRoute(routeType: type, avoidTolls: viewModel.avoidTolls, avoidFerries: viewModel.avoidFerries)
    }
}

extension DirectionVC: DirectionSearchViewOutputDelegate {
    func dismissView() {
        deleteScreenDrawing = false
        dismissHandler?()
    }
    
    func swapLocations() {
        (firstDestionation, secondDestionation) = (secondDestionation, firstDestionation)
        calculateRoute()
    }
}

extension DirectionVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = (manager.location?.coordinate.latitude, manager.location?.coordinate.longitude)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            NotificationCenter.default.post(name: Notification.Name("GrantedLocationPermissions"), object: nil, userInfo: ["userLocation": manager.location as Any])
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}
