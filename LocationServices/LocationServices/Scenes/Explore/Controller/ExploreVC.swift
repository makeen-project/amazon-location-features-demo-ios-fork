//
//  ExploreVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import CoreLocation

import AWSLocationXCF
import AWSMobileClientXCF
import AWSCore

final class ExploreVC: UIViewController, AlertPresentable {
    weak var delegate: ExploreNavigationDelegate?
    private var userCoreLocation: CLLocationCoordinate2D?
    
    var geofenceHandler: VoidHandler?
    
    var viewModel: ExploreViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private let exploreView: ExploreView = ExploreView()
    private let mapNavigationView = MapNavigationView()
    private lazy var locationManager: LocationManager = {
        let locationManager = LocationManager(alertPresenter: self)
        locationManager.setDelegate(self)
        return locationManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.navigationItem.backButtonTitle = ""
        setupHandlers()
        setupNotifications()
        
        exploreView.delegate = self
        
        locationManagerSetup()
        setupView()
        exploreView.setupTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        exploreView.shouldBottomStackViewPositionUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        exploreView.setupMapView()
        showWelcomeScreenIfNeeded()
    }
    
    func setupHandlers() {
        exploreView.geofenceButtonAction = {
            self.delegate?.dismissSearchScene()
            self.geofenceHandler?()
        }
    }
}

extension ExploreVC: ExploreViewOutputDelegate {
    func showMapStyles() {
        delegate?.showMapStyles()
    }
    
    func showNavigationView(steps: [NavigationSteps]) {
        
    }
    
    
    func showDirectionView(userLocation: CLLocationCoordinate2D?) {
        delegate?.showDirections(isRouteOptionEnabled: false,
                                 firstDestionation: nil,
                                 secondDestionation: nil,
                                 lat: userLocation?.latitude,
                                 long: userLocation?.longitude)
        exploreView.hideDirectionButton(state: true)
    }
    
    func showPoiCard(cardData: [MapModel]) {
        exploreView.shouldBottomStackViewPositionUpdate(state: true)
        exploreView.hideDirectionButton(state: true)
        delegate?.showPoiCardScene(cardData: cardData, lat: userCoreLocation?.latitude, long: userCoreLocation?.longitude)
    }
    
    func loginButtonTapped() {
        switch LoginViewModel.getAuthStatus() {
        case .authorized:
            showLogoutAlert()
        case .customConfig:
            (UIApplication.shared.delegate as? AppDelegate)?.navigationController = navigationController
            viewModel.login()
        case .defaultConfig:
            delegate?.showLoginFlow()
        }
    }
    
    func searchTextTapped(userLocation: CLLocationCoordinate2D?) {
        if let userLocation = userLocation {
            delegate?.showSearchSceneWith(lat: userLocation.latitude, long: userLocation.longitude)
        }
    }
    
    func getBottomSafeAreaWithTabBarHeight() -> CGFloat {
        let tabBarHeight = navigationController?.tabBarController?.tabBar.frame.height ?? 0
        let minimumBottomSheetHeight: CGFloat = 76
        return tabBarHeight + minimumBottomSheetHeight
    }
    
    func userLocationChanged(_ userLocation: CLLocationCoordinate2D) {
        viewModel.userLocationChanged(userLocation)
    }
    
    func performLocationDependentAction(_ action: () -> ()) {
        locationManager.performLocationDependentAction(action)
    }
    
    private func processAppRestartAfterAWSConnection() {
        guard UserDefaultsHelper.get(for: Bool.self, key: .showSignInOnAppStart) ?? false else { return }
        UserDefaultsHelper.save(value: false, key: .showSignInOnAppStart)
        
        if let customConnectFromSettings = UserDefaultsHelper.get(for: Bool.self, key: .awsCustomConnectFromSettings), customConnectFromSettings == false {
            delegate?.showLoginSuccess()
        }
    }
    
    private func showWelcomeScreenIfNeeded() {
        guard viewModel.shouldShowWelcome() else {
            processAppRestartAfterAWSConnection()
            return
        }
        
        delegate?.showWelcome()
    }
    
    func showPoiCard(for location: CLLocationCoordinate2D) {
        viewModel.loadPlace(for: location, userLocation: userCoreLocation)
    }
    
    func showAttribution() {
        delegate?.showAttribution()
    }
}

extension ExploreVC: ExploreViewModelOutputDelegate {
    func loginCompleted(_ presentation: ExplorePresentation) {
    }
    
    func logoutCompleted() {
    }
}

private extension ExploreVC {
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocation(_:)), name: Notification.userLocation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectPlace(_:)), name: Notification.selectedPlace, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateButtonConstraits(_:)), name: Notification.Name("updateMapViewButtons"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(drawDirectionRoute(_:)), name: Notification.Name("DirectionLineString"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showNavigationScene(_:)), name: Notification.Name("NavigationSteps"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissNavigationScene(_:)), name: Notification.Name("NavigationViewDismissed"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapViewValue(_:)), name: Notification.Name("UpdateMapViewValues"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissNavigationScene(_:)), name: Notification.Name("DirectionViewDismissed"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMapView(_:)), name: Notification.refreshMapView, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showWasResetToDefaultConfigAlert(_:)), name: Notification.wasResetToDefaultConfig, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchAppearanceChanged(_:)), name: Notification.searchAppearanceChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissPOICard(_:)), name: Notification.Name("POICardDismissed"), object: nil)
    }
    
    
    
    func setupView() {
        mapNavigationView.isHidden = true
        navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white
    
        self.view.addSubview(exploreView)
        exploreView.addSubview(mapNavigationView)
        
        exploreView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        mapNavigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaInsets).offset(53)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
    
    func locationManagerSetup() {
        locationManager.performLocationDependentAction {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    @objc private func updateMapViewValue(_ notification: Notification) {
        if let data = notification.userInfo?["MapViewValues"] as? (distance: String, street: String) {
            mapNavigationView.updateValues(distance: data.distance, street: data.street)
        }
    }
        
    @objc private func showWasResetToDefaultConfigAlert(_ notification: Notification) {
        let model = AlertModel(title: StringConstant.resetToDefaultConfigTitle, message: StringConstant.resetToDefaultConfigExplanation, cancelButton: nil)
        showAlert(model)
    }

    @objc private func drawDirectionRoute(_ notification: Notification) {
        guard let data = notification.userInfo?["LineString"] as? Data,
              let departureLocation = notification.userInfo?["DepartureLocation"] as? CLLocationCoordinate2D,
              let destinationLocation = notification.userInfo?["DestinationLocation"] as? CLLocationCoordinate2D,
              let routeType = notification.userInfo?["routeType"] as? RouteTypes else {
            return
        }
        
        exploreView.drawCalculatedRouteWith(data, departureLocation: departureLocation, destinationLocation: destinationLocation, isRecalculation: false, routeType: routeType)
    }
    
    @objc private func updateButtonConstraits(_ notification: Notification) {
        self.exploreView.shouldBottomStackViewPositionUpdate()
    }
    
    @objc private func updateLocation(_ notification: Notification) {
        if let location = notification.userInfo?["coordinates"] as? [MapModel] {
            self.exploreView.showPlacesOnMapWith(location)
        }
    }
    
    @objc private func selectPlace(_ notification: Notification) {
        if let place = notification.userInfo?["place"] as? MapModel {
            self.exploreView.show(selectedPlace: place)
        }
    }
    
    @objc private func showNavigationScene(_ notification: Notification) {
        if let datas = notification.userInfo?["steps"] as? (steps: [NavigationSteps], sumData: (totalDistance: Double, totalDuration: Double)),
        let routeModel = notification.userInfo?["routeModel"] as? RouteModel {
            viewModel.activateRoute(route: routeModel)
            if !routeModel.isPreview {
                mapNavigationView.isHidden = false
                exploreView.focusNavigationMode()
            } else {
                exploreView.focus(on: routeModel.departurePosition)
            }
            exploreView.hideGeoFence(state: true)
            exploreView.hideDirectionButton(state: true)
            let firstDestination = MapModel(placeName: routeModel.departurePlaceName, placeAddress: routeModel.departurePlaceAddress, placeLat: routeModel.departurePosition.latitude, placeLong: routeModel.departurePosition.longitude)
            let secondDestination = MapModel(placeName: routeModel.destinationPlaceName, placeAddress: routeModel.destinationPlaceAddress, placeLat: routeModel.destinationPosition.latitude, placeLong: routeModel.destinationPosition.longitude)
            
            self.delegate?.showNavigationview(steps: datas.steps,
                                              summaryData: datas.sumData,
                                              firstDestionation: firstDestination,
                                              secondDestionation: secondDestination)
        }
    }
    
    @objc private func dismissNavigationScene(_ notification: Notification?) {
        viewModel.deactivateRoute()
        exploreView.hideGeoFence(state: false)
        exploreView.hideDirectionButton(state: false)
        mapNavigationView.isHidden = true
        exploreView.deleteDrawing()
    }
    
    @objc private func dismissPOICard(_ notification: Notification?) {
        exploreView.hideDirectionButton(state: false)
    }
    
    @objc private func refreshMapView(_ notification: Notification) {
        exploreView.setupMapView()
    }
    
    @objc private func logoutAction() {
        viewModel.logout()
    }
        
    @objc private func searchAppearanceChanged(_ notification: Notification) {
        guard let isVisible = notification.userInfo?["isVisible"] as? Bool else { return }
        exploreView.searchBarView.isHidden = isVisible
    }
    
    /// Alert view refactored to generic later
    
    func showLogoutAlert() {
        let alert = UIAlertController(title: "Log out",
                                      message: "Are you sure you want to sign out? Geofence and Tracking information is not availabe without sign in", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .default,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "Log out",
                                      style: .destructive,
                                      handler: { _ in
            self.viewModel.logout()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ExploreVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userCoreLocation = manager.location?.coordinate
        exploreView.update(userLocation: manager.location, userHeading: manager.heading)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        exploreView.update(userLocation: manager.location, userHeading: manager.heading)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            NotificationCenter.default.post(name: Notification.Name("GrantedLocationPermissions"), object: nil, userInfo: ["userLocation": manager.location as Any])
            exploreView.grantedLocationPermissions()
        default:
            userCoreLocation = nil
            exploreView.update(userLocation: nil, userHeading: nil)
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    func routeReCalculated(route: DirectionPresentation, departureLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, routeType: RouteTypes) {
        let steps = route.navigationSteps
        let sumData = (route.distance, route.duration)
        
        let userInfo = ["steps": (steps: steps, sumData: sumData)]
        NotificationCenter.default.post(name: Notification.Name("NavigationStepsUpdated"), object: nil, userInfo: userInfo)
        
        let data = (try? JSONEncoder().encode(route.lineString)) ?? Data()
        self.exploreView.drawCalculatedRouteWith(data, departureLocation: departureLocation, destinationLocation: destinationLocation, isRecalculation: true, routeType: routeType)
    }
    
    func userReachedDestination(_ destination: MapModel) {
        dismissNavigationScene(nil)
        self.exploreView.show(selectedPlace: destination)
    }
    
    func showAnnotation(model: SearchPresentation) {
        showPoiCard(cardData: [MapModel(model: model)])
    }
}

extension ExploreVC: SearchVCOutputDelegate {
    func shareSearchData(with model: SearchPresentation) {
    }
}
