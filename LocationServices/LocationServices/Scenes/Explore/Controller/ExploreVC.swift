//
//  ExploreVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import CoreLocation

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        setupKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        exploreView.setupMapView()
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
                $0.top.equalTo(view.safeAreaInsets).offset(topOffset)
                $0.leading.equalToSuperview().offset(horizontalOffset)
                $0.trailing.equalToSuperview().offset(-horizontalOffset)
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
    
    func showNavigationView(steps: [RouteNavigationStep]) {
        
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
        Task {
            await viewModel.loadPlace(for: location, userLocation: userCoreLocation)
        }
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

extension ExploreVC {
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLocation(_:)), name: Notification.userLocation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(selectPlace(_:)), name: Notification.selectedPlace, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateButtonConstraits(_:)), name: Notification.Name("updateMapViewButtons"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(drawDirectionRoute(_:)), name: Notification.Name("DirectionLineString"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showNavigationScene(_:)), name: Notification.Name("NavigationSteps"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissNavigationScene(_:)), name: Notification.Name("NavigationViewDismissed"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapViewValue(_:)), name: Notification.Name("UpdateMapViewValues"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissDirectionScene(_:)), name: Notification.Name("DirectionViewDismissed"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMapView(_:)), name: Notification.refreshMapView, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showWasResetToDefaultConfigAlert(_:)), name: Notification.wasResetToDefaultConfig, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchAppearanceChanged(_:)), name: Notification.searchAppearanceChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exploreActionButtonsVisibilityChanged(_:)), name: Notification.exploreActionButtonsVisibilityChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapLayerItems(_:)), name: Notification.updateMapLayerItems, object: nil)
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
        if let data = notification.userInfo?["MapViewValues"] as? (distance: String, street: String) {
            mapNavigationView.updateValues(distance: data.distance, street: data.street)
        }
        if let data = notification.userInfo?["SummaryData"] as? (totalDistance: String, totalDuration: String) {
            mapNavigationActionsView.updateDatas(distance: data.totalDistance, duration: data.totalDuration)
        }
    }
    
    @objc private func updateMapLayerItems(_ notification: Notification) {
        guard !isInSplitViewController else { return }
        DispatchQueue.main.async {
            let size = self.view.bounds.size.height / 2 - 20
            let offset:CGFloat = (notification.userInfo?["height"] as? CGFloat) ?? size
            self.exploreView.updateBottomViewsSpacings(additionalBottomOffset: offset)
        }
    }
        
    @objc private func showWasResetToDefaultConfigAlert(_ notification: Notification) {
        let model = AlertModel(title: StringConstant.resetToDefaultConfigTitle, message: StringConstant.resetToDefaultConfigExplanation, cancelButton: nil)
        showAlert(model)
    }

    @objc private func drawDirectionRoute(_ notification: Notification) {
        guard let data = notification.userInfo?["LineString"] as? [Data],
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
        if let datas = notification.userInfo?["routeLegdetails"] as? (routeLegdetails: [RouteLegDetails]?, sumData: (totalDistance: Double, totalDuration: Double)),
        let routeModel = notification.userInfo?["routeModel"] as? RouteModel {
            viewModel.activateRoute(route: routeModel)
            if !routeModel.isPreview {
                mapNavigationView.isHidden = false
                updateAmazonLogoPositioning(isBottomNavigationShown: self.isInSplitViewController)
                exploreView.focusNavigationMode()
            } else {
                exploreView.focus(on: routeModel.departurePosition)
            }
            mapNavigationActionsView.isHidden = !self.isInSplitViewController
            let firstDestination = MapModel(placeName: routeModel.departurePlaceName, placeAddress: routeModel.departurePlaceAddress, placeLat: routeModel.departurePosition.latitude, placeLong: routeModel.departurePosition.longitude)
            let secondDestination = MapModel(placeName: routeModel.destinationPlaceName, placeAddress: routeModel.destinationPlaceAddress, placeLat: routeModel.destinationPosition.latitude, placeLong: routeModel.destinationPosition.longitude)
            
            self.delegate?.showNavigationview(routeLegDetails: datas.routeLegdetails!,
                                              summaryData: datas.sumData,
                                              firstDestination: firstDestination,
                                              secondDestination: secondDestination)
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
    
    @objc private func refreshMapView(_ notification: Notification) {
        exploreView.setupMapView()
    }
    
    @objc private func logoutAction() {
        viewModel.logout()
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
        if let routeLegDetails = route.routeLegDetails {
            
            let sumData = (route.distance, route.duration)
            let userInfo = ["routeLegDetails": (routeLegDetails: routeLegDetails, sumData: sumData)]
            NotificationCenter.default.post(name: Notification.Name("NavigationStepsUpdated"), object: nil, userInfo: userInfo)
            
            var datas: [Data] = []
            for legDetails in routeLegDetails {
                let data = (try? JSONEncoder().encode(legDetails.lineString)) ?? Data()
                datas.append(data)
            }
            self.exploreView.drawCalculatedRouteWith(datas, departureLocation: departureLocation, destinationLocation: destinationLocation, isRecalculation: true, routeType: routeType)
        }
    }
    
    func userReachedDestination(_ destination: MapModel) {
        dismissNavigationScene(nil)
        self.exploreView.show(selectedPlace: destination)
    }
    
    func showAnnotation(model: SearchPresentation, force: Bool) {
        guard force || (presentedViewController == nil && viewIfLoaded?.window != nil) else { return }
        showPoiCard(cardData: [MapModel(model: model)])
    }
}

extension ExploreVC: SearchVCOutputDelegate {
    func shareSearchData(with model: SearchPresentation) {
    }
}
