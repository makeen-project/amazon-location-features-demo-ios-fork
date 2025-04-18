//
//  TrackingVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import CoreLocation

final class TrackingVC: UIViewController {
    
    enum Constants {
        static let titleTopOffset: CGFloat = 27
        static let headerCornerRadius: CGFloat = 20
        static let trackingMapViewBottomOffset: CGFloat = 130
    }
    
    private var isiPad = UIDevice.current.userInterfaceIdiom == .pad
    
    var geofenceHandler: VoidHandler?
    var directionHandler: VoidHandler?
    
    private var isTrackingActive: Bool = false
    public var trackingMapView: TrackingMapView = TrackingMapView()
    private var userLocation: CLLocation?
    
    private lazy var locationManager: LocationManager = {
        let locationManager = LocationManager(alertPresenter: self)
        locationManager.setDelegate(self)
        return locationManager
    }()
    
    private let grabberIcon: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .searchBarTintColor
        button.layer.cornerRadius = 2.5
        return button
    }()
    
    private lazy var trackingHeaderView: TrackingHeaderView = {
        let view = TrackingHeaderView()
        view.backgroundColor = .white
        view.layer.cornerRadius = Constants.headerCornerRadius
        view.isUserInteractionEnabled = true
        return view
    }()
    
    weak var delegate: TrackingNavigationDelegate?
    private var isInSplitViewController: Bool { delegate is SplitViewTrackingMapCoordinator }
    
    var viewModel: TrackingViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackingMapView.reloadMap()
        tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(tabSelected(_:)), name: Notification.tabSelected, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backButtonTitle = ""
        self.view.backgroundColor = .white
        trackingMapView.delegate = self
        setupNotifications()
        setupHandlers()
        setupViews()
        locationManagerSetup()
        trackingHeaderView.isHidden = true
        if isiPad {
            grabberIcon.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.tabSelected, object: nil)
        removeGeofenceAnnotations()
    }
    
    private func setupHandlers() {
        trackingHeaderView.exitButtonHandler =  { [weak self] in
            let alertModel = AlertModel(title: StringConstant.exitTracking, message: StringConstant.exitTrackingAlertMessage, cancelButton: StringConstant.cancel, okButton: StringConstant.exit) {
                self?.trackingHeaderView.isHidden = true
                //show explore view
                NotificationCenter.default.post(name: Notification.dismissTrackingSimulation, object: self, userInfo: nil)
                if self?.isiPad == true {
                    NotificationCenter.default.post(name: Notification.showExploreScene, object: nil, userInfo: nil)
                }
                else {
                    self?.tabBarController?.selectedIndex = 0
                }
            }
            self?.showAlert(alertModel)
        }
    }
    
    func locationManagerSetup() {
        locationManager.performLocationDependentAction {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func removeGeofenceAnnotations() {
        trackingMapView.removeGeofencesFromMap()
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapLayerItems(_:)), name: Notification.updateMapLayerItems, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetMapLayerItems(_:)), name: Notification.resetMapLayerItems, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMapView(_:)), name: Notification.refreshMapView, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTrackingState(_:)), name: Notification.updateTrackingHeader, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(trackingAppearanceChanged(_:)), name: Notification.trackingAppearanceChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTrackingNotification(_:)), name: Notification.showTrackingNotification, object: nil)
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
        trackingMapView.updateBottomViewsSpacings(additionalBottomOffset: additionalOffset)
    }
    
    @objc override func keyboardWillHide(notification: NSNotification) {
        trackingMapView.updateBottomViewsSpacings(additionalBottomOffset: 0)
    }
    
    @objc private func refreshMapView(_ notification: Notification) {
        trackingMapView.reloadMap()
    }
    
    @objc private func resetMapLayerItems(_ notification: Notification) {
        guard !isInSplitViewController else { return }
        DispatchQueue.main.async {
            self.trackingMapView.updateBottomViewsSpacings(additionalBottomOffset: Constants.trackingMapViewBottomOffset)
        }
    }
    
    @objc private func updateMapLayerItems(_ notification: Notification) {
        guard !isInSplitViewController else { return }
        DispatchQueue.main.async {
            let size = self.view.bounds.size.height / 2 - 20
            let offset:CGFloat = ((notification.userInfo?["height"] as? CGFloat) ?? size)-80
            self.trackingMapView.updateBottomViewsSpacings(additionalBottomOffset: offset)
        }
    }
    
    @objc private func updateTrackingState(_ notification: Notification) {
        let state = (notification.userInfo?["state"] as? Bool) ?? false
        trackingHeaderView.isHidden = !state
        self.view.setNeedsLayout()
    }
    
    @objc private func tabSelected(_ notification: Notification) {
        guard let viewController = notification.userInfo?["viewController"] as? UIViewController,
              viewController === self || viewController === self.navigationController else { return }
    }
    
    @objc private func trackingAppearanceChanged(_ notification: Notification) {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        guard let isVisible = notification.userInfo?["isVisible"] as? Bool else { return }
        trackingHeaderView.isHidden = isVisible
        grabberIcon.isHidden = isVisible
    }
    
    @objc private func showTrackingNotification(_ notification: Notification) {
        guard let title = notification.userInfo?["title"] as? String,
              let message = notification.userInfo?["message"] as? String else {
            return
        }
        DispatchQueue.main.async {
            let banner = InAppNotificationBanner(title: title, message: message, image: GeneralHelper.getAppIcon())
            banner.show(in: self.view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.showDashboardFlow()
        setupKeyboardNotifications()
    }
    
    private func setupViews() {
        if !isInSplitViewController {
            self.trackingMapView.updateBottomViewsSpacings(additionalBottomOffset: Constants.trackingMapViewBottomOffset)
        }
        navigationController?.navigationBar.isHidden = !isInSplitViewController
        self.view.addSubview(trackingMapView)
        self.view.addSubview(trackingHeaderView)
        trackingMapView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        trackingHeaderView.snp.makeConstraints {
            if isiPad {
                $0.top.equalTo(view.safeAreaLayoutGuide).offset(70)
                $0.width.equalTo(350)
                $0.centerX.equalToSuperview()
            }
            else {
                $0.top.equalTo(view.safeAreaLayoutGuide)
                $0.leading.equalToSuperview().offset(16)
                $0.trailing.equalToSuperview().offset(-16)
            }

            $0.height.equalTo(40)
        }
    }
}

extension TrackingVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = manager.location
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        trackingMapView.update(userLocation: manager.location, userHeading: manager.heading)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            NotificationCenter.default.post(name: Notification.Name("GrantedLocationPermissions"), object: nil, userInfo: ["userLocation": manager.location as Any])
            trackingMapView.grantedLocationPermissions()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
}

extension TrackingVC: TrackingMapViewOutputDelegate {
    func showDirection() {
        self.directionHandler?()
    }
    
    func geofenceButtonAction() {
        Task {
            guard let lat = userLocation?.coordinate.latitude,
                  let long = userLocation?.coordinate.longitude else { return }
            try await GeofenceAPIService().evaluateGeofence(lat: lat, long: long, collectionName: GeofenceServiceConstant.collectionName)
            self.geofenceHandler?()
        }
    }
    
    func showMapLayers() {
        self.delegate?.showMapStyleScene()
    }
    
    func showAttribution() {
        delegate?.showAttribution()
    }
}

extension TrackingVC: TrackingViewModelDelegate {
    
    func removeGeofencesFromMap() {
        trackingMapView.removeGeofencesFromMap()
    }
    
    func showGeofences(routeId: String, _ models: [GeofenceDataModel]) {
        trackingMapView.showGeofenceAnnotations(models)
    }
    
    func drawTrackingRoute(routeId: String, coordinates: [CLLocationCoordinate2D]) {
        DispatchQueue.main.async {
            self.trackingMapView.drawTrackingRoute(routeId: routeId, coordinates: coordinates)
        }
    }
}
