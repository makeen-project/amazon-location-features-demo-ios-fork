//
//  TrackingVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import CoreLocation

final class TrackingVC: UIViewController, AlertPresentable {
    var geofenceHandler: VoidHandler?
    var directionHandler: VoidHandler?
    
    private var trackingMapView: TrackingMapView = TrackingMapView()
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
    
    private lazy var historyHeaderView: TrackingHistoryHeaderView = {
        let view = TrackingHistoryHeaderView()
        view.backgroundColor = .searchBarBackgroundColor
        view.layer.cornerRadius = 20
        view.isUserInteractionEnabled = true
        view.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let tap = UITapGestureRecognizer(target: self, action: #selector(openHistory))
        view.addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(openHistory))
        view.addGestureRecognizer(pan)
        
        return view
    }()
    
    weak var delegate: TrackingNavigationDelegate?
    
    var viewModel: TrackingViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    private let authActionsHelper = AuthActionsHelper()
    
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
        authActionsHelper.delegate = delegate
        setupNotifications()
        setupHandlers()
        setupViews()
        locationManagerSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopTracking()
        historyHeaderView.updateButtonStyle(isTrackingStarted: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.tabSelected, object: nil)
        removeGeofenceAnnotations()
    }
    
    private func setupHandlers() {
        historyHeaderView.trackingButtonHandler =  { [weak self] state in
            if UserDefaultsHelper.getAppState() == .loggedIn {
                NotificationCenter.default.post(name: Notification.updateStartTrackingButton, object: self, userInfo: ["state": state])
            } else  {
                self?.delegate?.showLoginFlow()
            }
        }
        
        historyHeaderView.showAlertCallback = showAlert(_:)
        historyHeaderView.showAlertControllerCallback = { [weak self] alertController in
            self?.present(alertController, animated: true)
        }
    }
    
    func locationManagerSetup() {
        locationManager.performLocationDependentAction {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func showGeofenceAnnotations() {
        viewModel.fetchListOfGeofences()
    }
    
    func removeGeofenceAnnotations() {
        trackingMapView.removeGeofencesFromMap()
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapLayerItems(_:)), name: Notification.updateMapLayerItems, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetMapLayerItems(_:)), name: Notification.resetMapLayerItems, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMapView(_:)), name: Notification.refreshMapView, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateButtonStyle(_:)), name: Notification.updateStartTrackingButton, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(trackingAppearanceChanged(_:)), name: Notification.trackingAppearanceChanged, object: nil)
    }
    
    @objc private func refreshMapView(_ notification: Notification) {
        trackingMapView.reloadMap()
    }
    
    @objc private func resetMapLayerItems(_ notification: Notification) {
        DispatchQueue.main.async {
            self.trackingMapView.adjustMapLayerItems(bottomSpace: 70)
        }
    }
    
    @objc private func updateMapLayerItems(_ notification: Notification) {
        DispatchQueue.main.async {
            let size = Int(self.view.bounds.size.height / 2 - 20)
            self.trackingMapView.adjustMapLayerItems(bottomSpace: size)
        }
    }
    
    @objc private func updateButtonStyle(_ notification: Notification) {
        let state = (notification.userInfo?["state"] as? Bool) ?? false
        if state {
            viewModel.startTracking()
            viewModel.trackLocationUpdate(location: userLocation)
            
            if (notification.object as? Self) === self {
                delegate?.showTrackingHistory(isTrackingActive: state)
            }
        } else {
            viewModel.stopTracking()
        }
        
        self.historyHeaderView.updateButtonStyle(isTrackingStarted: state)
        self.view.setNeedsLayout()
    }
    
    @objc private func tabSelected(_ notification: Notification) {
        guard let viewController = notification.userInfo?["viewController"] as? UIViewController,
              viewController === self || viewController === self.navigationController else { return }
        
        authActionsHelper.tryToPerformAuthAction {}
    }
    
    @objc func openHistory() {
        openLoginFlow(skipDashboard: true)
    }
    
    @objc private func trackingAppearanceChanged(_ notification: Notification) {
        guard let isVisible = notification.userInfo?["isVisible"] as? Bool else { return }
        historyHeaderView.isHidden = isVisible
        grabberIcon.isHidden = isVisible
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        openLoginFlow(skipDashboard: false)
        showGeofenceAnnotations()
    }
    
    func openLoginFlow(skipDashboard: Bool) {
        switch LoginViewModel.getAuthStatus() {
        case .authorized:
            trackingMapView.adjustMapLayerItems(bottomSpace: 70)
            if skipDashboard {
                delegate?.showTrackingHistory(isTrackingActive: viewModel.isTrackingActive)
            } else {
                delegate?.showNextTrackingScene()
            }
        case .customConfig:
            delegate?.showLoginSuccess()
        case .defaultConfig:
            delegate?.showLoginFlow()
        }
    }
    
    private func setupViews() {
        self.trackingMapView.adjustMapLayerItems(bottomSpace: 70)
        
        navigationController?.navigationBar.isHidden = true
        self.view.addSubview(trackingMapView)
        self.view.addSubview(historyHeaderView)
        self.view.addSubview(grabberIcon)
        
        trackingMapView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        historyHeaderView.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        grabberIcon.snp.makeConstraints {
            $0.bottom.equalTo(historyHeaderView.snp.top).offset(16)
            $0.width.equalTo(36)
            $0.height.equalTo(5)
            $0.centerX.equalToSuperview()
        }
    }
}

extension TrackingVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = manager.location
        viewModel.trackLocationUpdate(location: manager.location)
        trackingMapView.update(userLocation: manager.location, userHeading: manager.heading)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        trackingMapView.update(userLocation: manager.location, userHeading: manager.heading)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            viewModel.trackLocationUpdate(location: manager.location)
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
        guard let lat = userLocation?.coordinate.latitude,
              let long = userLocation?.coordinate.longitude else { return }
        GeofenceAPIService().evaluateGeofence(lat: lat, long: long)
        //        self.geofenceHandler?()
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
    
    func showGeofences(_ models: [GeofenceDataModel]) {
        trackingMapView.showGeofenceAnnotations(models)
    }
    
    func drawTrack(history: [TrackingHistoryPresentation]) {
        DispatchQueue.main.async {
            self.trackingMapView.drawTrack(history: history)
        }
    }
}
