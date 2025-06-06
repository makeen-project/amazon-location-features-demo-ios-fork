//
//  ExploreVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import CoreLocation
import AWSGeoRoutes

final class ExploreVC: UIViewController {
    
    enum Constants {
        static let navigationViewOptimalWidth: CGFloat = 361
        static let navigationViewHeight: CGFloat = 80
        static let defaultSpacing: CGFloat = 16
    }
    
    weak var delegate: ExploreNavigationDelegate?
    weak var splitDelegate: SplitViewVisibilityProtocol?
    private var isInSplitViewController: Bool { delegate is SplitViewExploreMapCoordinator }
    
    private(set) var userCoreLocation: CLLocationCoordinate2D?
    
    var geofenceHandler: VoidHandler?
    
    var viewModel: ExploreViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private let exploreView: ExploreView = ExploreView()
    private let mapNavigationView = MapNavigationView()
    let mapNavigationActionsView = NavigationHeaderView()
    private lazy var locationManager: LocationManager = {
        let locationManager = LocationManager(alertPresenter: self)
        locationManager.setDelegate(self)
        return locationManager
    }()
    
    private var isNavigationViewLeftAlignment: Bool {
        let countOfNavigationViewsInParentView = view.frame.width / Constants.navigationViewOptimalWidth
        return countOfNavigationViewsInParentView > 1.5
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHandlers()
        setupNotifications()
        
        exploreView.delegate = self
        
        locationManagerSetup()
        setupView()
        exploreView.setupMapView()
        exploreView.setupTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        exploreView.shouldBottomStackViewPositionUpdate()
        setupKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showWelcomeScreenIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setNavigationViewLayout()
    }
    
    private var parentViewWidthForNavigationViews: CGFloat = 0
    private func setNavigationViewLayout() {
        guard parentViewWidthForNavigationViews != view.frame.width else { return }
        
        let optimalWidth = Constants.navigationViewOptimalWidth
        let isLeftAlignment = isNavigationViewLeftAlignment
        
        let topOffset: CGFloat = 53
        let horizontalOffset: CGFloat = Constants.defaultSpacing
        
        if isLeftAlignment {
            mapNavigationView.snp.remakeConstraints {
                $0.top.equalTo(view.safeAreaInsets).offset(topOffset)
                $0.leading.equalToSuperview().offset(horizontalOffset)
                $0.width.equalTo(optimalWidth)
            }
            mapNavigationActionsView.snp.remakeConstraints {
                $0.bottom.equalTo(view.safeAreaInsets)
                $0.leading.equalToSuperview().offset(horizontalOffset)
                $0.width.equalTo(optimalWidth)
                $0.height.equalTo(Constants.navigationViewHeight)
            }
        } else {
            mapNavigationView.snp.remakeConstraints {
                $0.top.equalToSuperview()
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
            mapNavigationActionsView.snp.remakeConstraints {
                $0.bottom.equalTo(view.safeAreaInsets)
                $0.leading.equalToSuperview().offset(horizontalOffset)
                $0.trailing.equalToSuperview().offset(-horizontalOffset)
                $0.height.equalTo(Constants.navigationViewHeight)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        removeKeyboardNotifications()
    }
    
    func setupHandlers() {
        exploreView.geofenceButtonAction = {
            self.delegate?.dismissSearchScene()
            self.geofenceHandler?()
        }
    }
    
    func applyStyles(style: SearchScreenStyle) {
        exploreView.searchBarView.applyStyle(style.searchBarStyle)
    }
}

extension ExploreVC: ExploreViewOutputDelegate {
    func showMapStyles() {
        delegate?.showMapStyles()
    }
    
    func showNavigationView(steps: [GeoRoutesClientTypes.RouteVehicleTravelStep]) {
        
    }
    
    
    func showDirectionView(userLocation: CLLocationCoordinate2D?) {
        delegate?.showDirections(isRouteOptionEnabled: false,
                                 firstDestination: nil,
                                 secondDestination: nil,
                                 lat: userLocation?.latitude,
                                 long: userLocation?.longitude)
    }
    
    func showPoiCard(cardData: [MapModel]) {
        exploreView.shouldBottomStackViewPositionUpdate(state: true)
        delegate?.showPoiCardScene(cardData: cardData, lat: userCoreLocation?.latitude, long: userCoreLocation?.longitude)
    }
    
    func showArrivalCard(route: RouteModel) {
        exploreView.shouldBottomStackViewPositionUpdate(state: true)
        exploreView.hideGeoFence(state: true)
        delegate?.showArrivalCardScene(route: route)
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
    
    private func showWelcomeScreenIfNeeded() {
        guard viewModel.shouldShowWelcome() else {
            return
        }
        
        delegate?.showWelcome()
    }
    
    func showPoiCard(for location: CLLocationCoordinate2D) {
        Task {
            await viewModel.loadPlace(for: location, userLocation: userCoreLocation)
        }
    }
    
    func showAttribution() {
        delegate?.showAttribution()
    }
}

extension ExploreVC: ExploreViewModelOutputDelegate {
}

extension ExploreVC {

    func setupNotifications() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocation(_:)), name: Notification.userLocation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectPlace(_:)), name: Notification.selectedPlace, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateButtonConstraits(_:)), name: Notification.updateMapViewButtons, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(drawDirectionRoute(_:)), name: Notification.directionLineString, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.navigationSteps, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showNavigationScene(_:)), name: Notification.navigationSteps, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissNavigationScene(_:)), name: Notification.navigationViewDismissed, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapViewValue(_:)), name: Notification.updateMapViewValues, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissDirectionScene(_:)), name: Notification.directionViewDismissed, object: nil)
        
    
        NotificationCenter.default.addObserver(self, selector: #selector(shownSearchResults(_:)), name: Notification.shownSearchResults, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMapView(_:)), name: Notification.refreshMapView, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(searchAppearanceChanged(_:)), name: Notification.searchAppearanceChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exploreActionButtonsVisibilityChanged(_:)), name: Notification.exploreActionButtonsVisibilityChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapLayerItems(_:)), name: Notification.updateMapLayerItems, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(focusOnLocation(_:)), name: Notification.focusOnLocation, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeNotificationObservers(_:)), name: Notification.removeNotificationObservers, object: nil)
    }
    
    private func setupKeyboardNotifications() {
        guard isInSplitViewController else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotifications() {
        guard isInSplitViewController else { return }
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc override func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let additionalOffset = keyboardSize.height - view.safeAreaInsets.bottom
        exploreView.updateBottomViewsSpacings(additionalBottomOffset: additionalOffset)
    }
    
    @objc override func keyboardWillHide(notification: NSNotification) {
        exploreView.updateBottomViewsSpacings(additionalBottomOffset: 0)
    }
    
    func setupView() {
        mapNavigationView.isHidden = true
        mapNavigationActionsView.isHidden = true
        //updateAmazonLogoPositioning(isBottomNavigationShown: false)
        mapNavigationActionsView.update(style: .navigationActions)
        changeSeachBarVisibility(isHidden: false)
        if !isInSplitViewController {
            self.navigationItem.backButtonTitle = ""
            navigationController?.navigationBar.isHidden = true
        }
        self.view.backgroundColor = .white
    
        self.view.addSubview(exploreView)
        exploreView.addSubview(mapNavigationView)
        exploreView.addSubview(mapNavigationActionsView)
        
        exploreView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            if isInSplitViewController {
                $0.bottom.equalToSuperview()
            } else {
                $0.bottom.equalTo(view.safeAreaLayoutGuide)
            }
            
        }
        
        setNavigationViewLayout()
        
        mapNavigationActionsView.dismissHandler = { [weak self] in
            self?.delegate?.closeNavigationScene()
        }
        
        mapNavigationActionsView.switchRouteVisibility = { [weak self] state in
            switch state {
            case .hideRoute:
                self?.splitDelegate?.showOnlySecondary()
            case .showRoute:
                self?.splitDelegate?.showSupplementary()
            }
        }
    }
    
    private func updateAmazonLogoPositioning(isBottomNavigationShown: Bool) {
        let leadingOffset: CGFloat?
        let bottomOffset: CGFloat?
        
        if isBottomNavigationShown {
            if isNavigationViewLeftAlignment {
                leadingOffset = Constants.navigationViewOptimalWidth + Constants.defaultSpacing * 2
                bottomOffset = nil
            } else {
                leadingOffset = nil
                bottomOffset = Constants.navigationViewHeight + Constants.defaultSpacing * 2
            }
        } else {
            leadingOffset = nil
            bottomOffset = nil
        }
        
        exploreView.setupAmazonLogo(bottomOffset: bottomOffset)
    }
    
    private func changeSeachBarVisibility(isHidden: Bool) {
        if isInSplitViewController {
            exploreView.searchBarView.isHidden = true
        } else {
            exploreView.searchBarView.isHidden = isHidden
        }
    }
    
    func locationManagerSetup() {
        locationManager.performLocationDependentAction {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    @objc private func updateMapViewValue(_ notification: Notification) {
        if let data = notification.userInfo?["MapViewValues"] as? (distance: String, street: String, stepImage: UIImage?) {
            mapNavigationView.updateValues(distance: data.distance, street: data.street, stepImage: data.stepImage)
        }
        if let data = notification.userInfo?["SummaryData"] as? (totalDistance: String, totalDuration: String, arrivalTime: String) {
            mapNavigationActionsView.updateDatas(distance: data.totalDistance, duration: data.totalDuration, arrivalTime: data.arrivalTime)
        }
    }
    
    @objc private func updateMapLayerItems(_ notification: Notification) {
        guard !isInSplitViewController else { return }
        DispatchQueue.main.async {
            let size = self.view.bounds.size.height / 2 - 20
            let offset:CGFloat = ((notification.userInfo?["height"] as? CGFloat) ?? size)-80
            self.exploreView.updateBottomViewsSpacings(additionalBottomOffset: offset)
        }
    }

    @objc private func drawDirectionRoute(_ notification: Notification) {
        guard let data = notification.userInfo?["LineString"] as? [Data],
              let departureLocation = notification.userInfo?["DepartureLocation"] as? CLLocationCoordinate2D,
              let destinationLocation = notification.userInfo?["DestinationLocation"] as? CLLocationCoordinate2D,
              let routeType = notification.userInfo?["routeType"] as? RouteTypes,
              let isPreview = notification.userInfo?["isPreview"] as? Bool else {
            return
        }
        
        exploreView.drawCalculatedRouteWith(data, departureLocation: departureLocation, destinationLocation: destinationLocation, isRecalculation: false, routeType: routeType, isPreview: isPreview)
    }
    
    @objc private func updateButtonConstraits(_ notification: Notification) {
        self.exploreView.shouldBottomStackViewPositionUpdate()
    }
    
    @objc private func updateLocation(_ notification: Notification) {
        if let location = notification.userInfo?["coordinates"] as? [MapModel] {
            self.exploreView.showPlacesOnMapWith(location)
        }
    }
    
    @objc private func focusOnLocation(_ notification: Notification) {
        if let location = notification.userInfo?["coordinates"] as? CLLocationCoordinate2D {
            self.exploreView.focus(on: location)
        }
    }
    
    @objc private func selectPlace(_ notification: Notification) {
        if let place = notification.userInfo?["place"] as? MapModel {
            self.exploreView.show(selectedPlace: place)
        }
    }
    
    @objc private func showNavigationScene(_ notification: Notification) {
        if let datas = notification.userInfo?["route"] as? GeoRoutesClientTypes.Route,
        let routeModel = notification.userInfo?["routeModel"] as? RouteModel {
            viewModel.activateRoute(route: routeModel)
            mapNavigationView.isHidden = false
            updateAmazonLogoPositioning(isBottomNavigationShown: self.isInSplitViewController)
            
            mapNavigationActionsView.isHidden = !self.isInSplitViewController
            let firstDestination = MapModel(placeName: routeModel.departurePlaceName, placeAddress: routeModel.departurePlaceAddress, placeLat: routeModel.departurePosition.latitude, placeLong: routeModel.departurePosition.longitude)
            let secondDestination = MapModel(placeName: routeModel.destinationPlaceName, placeAddress: routeModel.destinationPlaceAddress, placeLat: routeModel.destinationPosition.latitude, placeLong: routeModel.destinationPosition.longitude)
            
            self.delegate?.showNavigationview(route: datas,
                                              firstDestination: firstDestination,
                                              secondDestination: secondDestination)
            if !routeModel.isPreview {
                exploreView.focusNavigationMode()
            }
            else {
                exploreView.focus(on: routeModel.departurePosition)
            }
        }
    }
    
    @objc private func dismissNavigationScene(_ notification: Notification?) {
        viewModel.deactivateRoute()
        mapNavigationView.isHidden = true
        mapNavigationActionsView.isHidden = true
        //updateAmazonLogoPositioning(isBottomNavigationShown: false)
        exploreView.hideGeoFence(state: false)
        exploreView.deleteDrawing()
    }
    
    @objc private func dismissDirectionScene(_ notification: Notification?) {
        viewModel.deactivateRoute()
        exploreView.hideDirectionButton(state: false)
        exploreView.hideGeoFence(state: false)
        exploreView.hideMapStyleButton(state: false)
        exploreView.deleteDrawing()
    }
    
    @objc private func shownSearchResults(_ notification: Notification?) {
        viewModel.deactivateRoute()
        exploreView.deleteDrawing()
    }
    
    
    @objc private func refreshMapView(_ notification: Notification) {
        exploreView.setupMapView(locateMe: false)
    }
        
    @objc private func searchAppearanceChanged(_ notification: Notification) {
        guard let isVisible = notification.userInfo?["isVisible"] as? Bool else { return }
        changeSeachBarVisibility(isHidden: isVisible)
    }
    
    @objc private func exploreActionButtonsVisibilityChanged(_ notification: Notification) {
        if let geofenceIsHidden = notification.userInfo?[StringConstant.NotificationsInfoField.geofenceIsHidden] as? Bool {
            exploreView.hideGeoFence(state: geofenceIsHidden)
        }
        if let directionIsHidden = notification.userInfo?[StringConstant.NotificationsInfoField.directionIsHidden] as? Bool {
            exploreView.hideDirectionButton(state: directionIsHidden)
        }
        if let mapStyleIsHidden = notification.userInfo?[StringConstant.NotificationsInfoField.mapStyleIsHidden] as? Bool {
            exploreView.hideMapStyleButton(state: mapStyleIsHidden)
        }
    }
}

extension ExploreVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userCoreLocation = manager.location?.coordinate
        exploreView.update(userLocation: manager.location, userHeading: manager.heading)
        if let isNavigationMode = UserDefaultsHelper.get(for: Bool.self, key: .isNavigationMode), isNavigationMode, let route = UserDefaultsHelper.getObject(value: RouteModel.self, key: .navigationRoute), let userCoreLocation = userCoreLocation, isArrivalInProximity(userCoreLocation: userCoreLocation, route: route) {
            NotificationCenter.default.post(name: Notification.navigationViewDismissed, object: nil, userInfo: nil)
            self.showArrivalCard(route: route)
        }
    }
    
    func isArrivalInProximity(userCoreLocation: CLLocationCoordinate2D, route: RouteModel) -> Bool {
        let distance = userCoreLocation.distance(from: route.destinationPosition)
        switch route.travelMode {
        case .car, .truck:
            return distance < 50
        case .pedestrian:
            return distance < 15
        case .scooter:
            return distance < 30
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        exploreView.update(userLocation: manager.location, userHeading: manager.heading)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            NotificationCenter.default.post(name: Notification.grantedLocationPermissions, object: nil, userInfo: ["userLocation": manager.location as Any])
            exploreView.grantedLocationPermissions()
        default:
            userCoreLocation = nil
            exploreView.update(userLocation: nil, userHeading: nil)
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    func routeReCalculated(direction: DirectionPresentation, departureLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, routeType: RouteTypes, isPreview: Bool) {
            let userInfo = ["route": direction.route]
        NotificationCenter.default.post(name: Notification.navigationStepsUpdated, object: nil, userInfo: userInfo)
            let encoder = JSONEncoder()
            do {
                var datas: [Data] = []
                if let legDetails = direction.route.legs {
                    for leg in legDetails {
                        let data = try encoder.encode(leg.geometry?.getPolylineGeoData())
                        datas.append(data)
                    }
                }
                self.exploreView.drawCalculatedRouteWith(datas, departureLocation: departureLocation, destinationLocation: destinationLocation, isRecalculation: true, routeType: routeType, isPreview: isPreview)
            } catch {
                print(String.errorJSONDecoder)
            }
    }
    
    func userReachedDestination(_ destination: MapModel) {
        dismissNavigationScene(nil)
    }
    
    func showAnnotation(model: SearchPresentation, force: Bool) {
        DispatchQueue.main.async { [self] in
            guard force || (presentedViewController == nil && viewIfLoaded?.window != nil) else { return }
            showPoiCard(cardData: [MapModel(model: model)])
        }
    }
}

extension ExploreVC: SearchVCOutputDelegate {
    func shareSearchData(with model: SearchPresentation) {
    }
}
