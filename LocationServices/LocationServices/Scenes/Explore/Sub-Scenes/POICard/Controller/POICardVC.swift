//
//  POICardVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import CoreLocation

final class POICardVC: UIViewController, UIViewControllerTransitioningDelegate {
    
    enum DetentsSizeClass {
        case allInfo
        case noDistanceValues
        
        var height: CGFloat {
            switch self {
            case .allInfo:
                return 200
            case .noDistanceValues:
                return 174
            }
        }
    }
    
    enum Constants {
        static let titleOffsetiPhone: CGFloat = 20
        static let titleOffsetiPad: CGFloat = 0
    }
    
    private lazy var locationManager: LocationManager = {
        let locationManager = LocationManager(alertPresenter: self)
        return locationManager
    }()
    
    private lazy var poiCardView: POICardView = {
        let titleTopOffset: CGFloat = isInSplitViewController ? Constants.titleOffsetiPad : Constants.titleOffsetiPhone
        return POICardView(titleTopOffset: titleTopOffset, isCloseButtonHidden: isInSplitViewController)
    }()
    weak var delegate: ExploreNavigationDelegate?
    private var isInSplitViewController: Bool { delegate is SplitViewExploreMapCoordinator }
    var userLocation: (lat: Double?, long: Double?)?
    
    private var authorizationStatusChanged: Bool = false
    private var shouldOpenDirections: Bool = false
    
    var viewModel: POICardViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .searchBarBackgroundColor
        locationManager.setDelegate(self)
        poiCardView.delegate = self
        Task {
            try await viewModel.fetchDatas()
        }
        setupViews()
        
        let barButtonItem = UIBarButtonItem(title: nil, image: .chevronBackward, target: self, action: #selector(dismissPoiView))
        barButtonItem.tintColor = .lsPrimary
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showCurrentAnnotation()
        changeExploreActionButtonsVisibility()
    }
        
    private func setupViews() {
        self.view.addSubview(poiCardView)
        poiCardView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func changeExploreActionButtonsVisibility() {
        let userInfo = [
            StringConstant.NotificationsInfoField.geofenceIsHidden: false,
            StringConstant.NotificationsInfoField.directionIsHidden: false
        ]
        NotificationCenter.default.post(name: Notification.exploreActionButtonsVisibilityChanged, object: nil, userInfo: userInfo)
    }
    
    private func updateMapViewBottomIcons() {
        NotificationCenter.default.post(name: Notification.Name("updateMapViewButtons"), object: nil, userInfo: nil)
    }
    
    private func clearAnnotations() {
        let coordinates: [String: [MapModel]] = ["coordinates" : []]
        NotificationCenter.default.post(name: Notification.userLocation, object: nil, userInfo: coordinates)
    }
    
    private func showCurrentAnnotation() {
        guard let mapModel = viewModel.getMapModel() else { return }
        let coordinates = ["coordinates" : [mapModel]]
        NotificationCenter.default.post(name: Notification.userLocation, object: nil, userInfo: coordinates)
    }
    
    private func showLocationPermissionsAlert(seconDestination: MapModel) {
        let alert = UIAlertController(title: StringConstant.locationPermissionAlertTitle, message:  StringConstant.locationPermissionAlertText, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: StringConstant.locationPermissionEnableLocationAction, style: .default, handler: { [weak self] _ in
            self?.shouldOpenDirections = true
            self?.locationManager.requestPermissions()
        }))
        alert.addAction(UIAlertAction(title: StringConstant.continueString, style: .default, handler: { [weak self] _ in
            self?.showDirections(secondDestination: seconDestination)
        }))
        
        alert.addAction(UIAlertAction(title: StringConstant.cancel, style: .default))
        present(alert, animated: true)
    }
}

extension POICardVC: POICardViewModelOutputDelegate {
    func populateDatas(cardData: MapModel, isLoadingData: Bool, errorMessage: String?, errorInfoMessage: String?) {
        DispatchQueue.main.async { [self] in
            poiCardView.isLoadingData = isLoadingData
            poiCardView.errorMessage = errorMessage
            poiCardView.errorInfoMessage = errorInfoMessage
            poiCardView.dataModel = cardData
        }
    }
    
    @objc func dismissPoiView() {
        DispatchQueue.main.async { [self] in
            clearAnnotations()
            updateMapViewBottomIcons()
            NotificationCenter.default.post(name: Notification.Name("DirectionViewDismissed"), object: nil, userInfo: nil)
            if(isInSplitViewController){
                self.navigationController?.popViewController(animated: true)
            }
            else{
                self.view.removeFromSuperview()
            }
        }
    }
    
    func showDirections(secondDestination: MapModel) {
        DispatchQueue.main.async { [self] in
            delegate?.showDirections(isRouteOptionEnabled: true,
                                     firstDestination: nil,
                                     secondDestination: secondDestination,
                                     lat: userLocation?.lat,
                                     long: userLocation?.long)
        }
    }
    
    func showDirectionView(seconDestination: MapModel) {
        DispatchQueue.main.async { [self] in
            switch locationManager.getAuthorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                showDirections(secondDestination: seconDestination)
            default:
                showLocationPermissionsAlert(seconDestination: seconDestination)
            }
        }
    }
    
    func updateSizeClass(_ sizeClass: DetentsSizeClass) {
        let smallId = UISheetPresentationController.Detent.Identifier("small")
        let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallId) { context in
            return sizeClass.height
        }
        sheetPresentationController?.detents = [smallDetent]
        sheetPresentationController?.largestUndimmedDetentIdentifier = smallId
    }
    
    func setPOIHeight(_ height: CGFloat)
    {
        self.setBottomSheetHeight(to: height)
    }
}

extension POICardVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = manager.location?.coordinate
        userLocation = (coordinate?.latitude, coordinate?.longitude)
        viewModel.setUserLocation(lat: coordinate?.latitude, long: coordinate?.longitude)
        
        guard authorizationStatusChanged else { return }
        authorizationStatusChanged = false
        if shouldOpenDirections {
            if let mapModel = viewModel.getMapModel() {
                showDirections(secondDestination: mapModel)
            }
        } else {
            Task {
                try await viewModel.fetchDatas()
            }
        }
        shouldOpenDirections = false
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            NotificationCenter.default.post(name: Notification.Name("GrantedLocationPermissions"), object: nil, userInfo: ["userLocation": manager.location as Any])
            authorizationStatusChanged = true
        default:
            userLocation = nil
            viewModel.setUserLocation(lat: nil, long: nil)
            Task {
                try await viewModel.fetchDatas()
            }
            break
        }
    }
}
