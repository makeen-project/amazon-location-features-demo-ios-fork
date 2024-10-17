//
//  DirectionVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import CoreLocation

struct DirectionScreenStyle {
    var backgroundColor: UIColor
}

final class DirectionVC: UIViewController {
    
    enum Constants {
        static let mediumId = UISheetPresentationController.Detent.Identifier("medium")
        static let titleOffsetiPhone: CGFloat = 20
        static let titleOffsetiPad: CGFloat = 0
    }
    
    var directionScreenStyle: DirectionScreenStyle = DirectionScreenStyle(backgroundColor: .white)
    var isInSplitViewController: Bool = false
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
    lazy var locationManager: LocationManager = {
        let locationManager = LocationManager(alertPresenter: self)
        locationManager.setDelegate(self)
        return locationManager
    }()
    
    var isDestination: Bool = true
    
    var viewModel: DirectionViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    lazy var directionSearchView: DirectionSearchView = {
        let titleTopOffset: CGFloat = isInSplitViewController ? Constants.titleOffsetiPad : Constants.titleOffsetiPhone
        return DirectionSearchView(titleTopOffset: titleTopOffset, isCloseButtonHidden: isInSplitViewController)
    }()
    
    lazy var directionView: DirectionView = DirectionView()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.accessibilityIdentifier = ViewsIdentifiers.Routing.tableView
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
        applyStyles()
        viewModel.loadLocalOptions()
        
        if firstDestionation?.placeName == "My Location" {
            directionSearchView.setMyLocationText()
        }
        locationManagerSetup()
        
        let barButtonItem = UIBarButtonItem(title: nil, image: .chevronBackward, target: self, action: #selector(dismissView))
        barButtonItem.tintColor = .lsPrimary
        navigationItem.leftBarButtonItem = barButtonItem
        
        tableView.isHidden = isRoutingOptionsEnabled
        if isRoutingOptionsEnabled {
            sheetPresentationController?.selectedDetentIdentifier = Constants.mediumId
        } else {
            let isDestination = firstDestionation?.placeName != nil
            directionSearchView.becomeFirstResponder(isDestination: isDestination)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            try await calculateRoute()
        }
        changeExploreActionButtonsVisibility(geofenceIsHidden: false, directionIsHidden: true, mapStyleIsHidden: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotifications()
    }
    
    private func applyStyles() {
        tableView.backgroundColor = directionScreenStyle.backgroundColor
        view.backgroundColor = directionScreenStyle.backgroundColor
    }
    
    private func locationManagerSetup() {
        locationManager.performLocationDependentAction {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    private func changeExploreActionButtonsVisibility(geofenceIsHidden: Bool, directionIsHidden: Bool, mapStyleIsHidden: Bool) {
        let userInfo = [
            StringConstant.NotificationsInfoField.geofenceIsHidden: geofenceIsHidden,
            StringConstant.NotificationsInfoField.directionIsHidden: directionIsHidden,
            StringConstant.NotificationsInfoField.mapStyleIsHidden: mapStyleIsHidden
        ]
        NotificationCenter.default.post(name: Notification.exploreActionButtonsVisibilityChanged, object: nil, userInfo: userInfo)
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
            Task {
                await self?.viewModel.searchWithSuggestion(text: model.searchText,
                                                            userLat: self?.userLocation?.lat,
                                                            userLong: self?.userLocation?.long)
            }
        }
        
        directionSearchView.searchReturnHandler = { [weak self] model in
            self?.isDestination = model.isDestination
            self?.directionView.isHidden = true
            self?.tableView.isHidden = false
            Task {
               try await self?.viewModel.searchWith(text: model.searchText,
                                           userLat: self?.userLocation?.lat,
                                           userLong: self?.userLocation?.long)
            }
        }
        
        directionView.avoidTolls = { [weak self] state in
            let travelModel = self?.viewModel.selectedTravelMode
            let avoidFerries = self?.viewModel.avoidFerries
            Task {
                try await self?.calculateRoute(routeType: travelModel ?? .car,
                                               avoidTolls: state,
                                               avoidFerries: avoidFerries ?? false)
            }
        }
        
        directionView.avoidFerries = { [weak self] state in
            let travelModel = self?.viewModel.selectedTravelMode
            let avoidToll = self?.viewModel.avoidTolls
            Task {
               try await self?.calculateRoute(routeType: travelModel ?? .car,
                                     avoidTolls: avoidToll ?? false,
                                     avoidFerries: state)
            }
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
        Task {
            try await calculateRoute()
        }
    }
    
    private func setupViews() {
        directionSearchView.changeSearchRouteName(with: firstDestionation?.placeName, isDestination: false)
        directionSearchView.changeSearchRouteName(with: secondDestionation?.placeName, isDestination: true)
        //let scrollView = UIScrollView()
        
        self.view.addSubview(directionSearchView)
        //self.view.addSubview(scrollView)
        self.view.addSubview(directionView)
        self.view.addSubview(tableView)
        
//        scrollView.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(10)
//            $0.trailing.leading.bottom.equalToSuperview()
//        }
        
        directionSearchView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().offset(14)
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(140)
            $0.width.equalToSuperview()
        }
        
        directionView.snp.makeConstraints {
            $0.top.equalTo(directionSearchView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(560)
            $0.width.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(directionSearchView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.width.equalToSuperview()
        }

        directionView.isHidden = true
    }
    
    private func calculateRoute(routeType: RouteTypes = .car,
                                avoidTolls: Bool = false,
                                avoidFerries: Bool = false) async throws {
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
        try await calculateGenericRoute(currentModel: currentModel,
                              routeType: routeType,
                              avoidFerries: avoidFerries,
                              avoidTolls: avoidTolls)
    }
    
    func setupSearchTitleDestinations() {
        self.directionSearchView.changeSearchRouteName(with: firstDestionation?.placeName ?? "", isDestination: false)
        self.directionSearchView.changeSearchRouteName(with: secondDestionation?.placeName ?? "", isDestination: true)
    }
    
    func calculateGenericRoute(currentModel: SearchCellViewModel, routeType: RouteTypes = .car, avoidFerries: Bool = false, avoidTolls: Bool = false) async throws {
        
        guard let (departureLocation, destinationLocation) = getRouteLocations(currentModel: currentModel) else { return }
        
        guard isDistanceValid(departureLoc: departureLocation, destinationLoc: destinationLocation) else { return }
        if let (data, directionVM) = try await viewModel.calculateRouteWith(destinationPosition: destinationLocation,
                                     departurePosition: departureLocation,
                                     travelMode: routeType,
                                     avoidFerries: avoidFerries,
                                     avoidTolls: avoidTolls) {
            
            self.tableView.isHidden = true
            self.directionView.isHidden = false
            
            let isPreview = self.firstDestionation?.placeName != "My Location"
            self.directionView.setup(model: directionVM, isPreview: isPreview)
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
    
    func calculateRoute() async throws  {
        updateMyLocationDestination()
        
        if let departureLat = firstDestionation?.lat, let departureLong = firstDestionation?.long, let destionationLat = secondDestionation?.lat, let destinationLong = secondDestionation?.long {
            
            let departureLoc = CLLocationCoordinate2D(latitude: departureLat, longitude: departureLong)
            let destionationLoc = CLLocationCoordinate2D(latitude: destionationLat, longitude: destinationLong)
            
            guard isDistanceValid(departureLoc: departureLoc, destinationLoc: destionationLoc) else { return }
            if let (data, directionVM) = try await viewModel.calculateRouteWith(destinationPosition: destionationLoc, departurePosition: departureLoc, avoidFerries: viewModel.avoidFerries, avoidTolls: viewModel.avoidTolls) {
                
                self.tableView.isHidden = true
                self.directionView.isHidden = false
                
                DispatchQueue.main.async {
                    self.directionView.showOptionsStackView()
                }
                
                let isPreview = self.firstDestionation?.placeName != "My Location"
                self.directionView.setup(model: directionVM, isPreview: isPreview)
                
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
        //May implement this later if there is limit on distance
        return true
    }
}

extension DirectionVC: DirectionViewModelOutputDelegate {
    func getLocalRouteOptions(tollOption: Bool, ferriesOption: Bool) {
        directionView.setLocalValues(toll: tollOption, ferries: ferriesOption)
    }
    
    func selectedPlaceResult(mapModel: [MapModel]) async throws {
        
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
            try await calculateGenericRoute(currentModel: currentModel, avoidFerries: viewModel.avoidFerries, avoidTolls: viewModel.avoidTolls)
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
        case .success(let routeLegdetails):
            let routeModel = self.getRouteModel(for: type)
            let sumData = self.viewModel.getSumData(type)
            
            if self.viewModel.selectedTravelMode != type {
                Task {
                    try await self.changeRoute(type: type)
                }
            }
            
            let userInfo = ["routeLegdetails" : (routeLegdetails: routeLegdetails, sumData: sumData), "routeModel": routeModel as Any] as [String : Any]
            NotificationCenter.default.post(name: Notification.Name("NavigationSteps"), object: nil, userInfo: userInfo)
        case .failure(let error):
            let alertModel = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
            self.showAlert(alertModel)
        }
    }
    
    func changeRoute(type: RouteTypes) async throws {
        try await calculateRoute(routeType: type, avoidTolls: viewModel.avoidTolls, avoidFerries: viewModel.avoidFerries)
    }
}

extension DirectionVC: DirectionSearchViewOutputDelegate {
    @objc func dismissView() {
        changeExploreActionButtonsVisibility(geofenceIsHidden: true, directionIsHidden: true, mapStyleIsHidden: true)
        dismissHandler?()
    }
    
    func swapLocations() async throws {
        (firstDestionation, secondDestionation) = (secondDestionation, firstDestionation)
        try await calculateRoute()
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
