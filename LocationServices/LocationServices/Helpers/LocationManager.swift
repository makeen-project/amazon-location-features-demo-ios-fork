//
//  LocationManager.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import CoreLocation

class LocationManager {
    private let locationManager: CLLocationManagerProtocol
    private let alertPresenter: AlertPresentable
    
    init(alertPresenter: AlertPresentable, locationManager: CLLocationManagerProtocol = CLLocationManager()) {
        self.alertPresenter = alertPresenter
        self.locationManager = locationManager
    }
    
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    func setDelegate(_ delegate: CLLocationManagerDelegate) {
        locationManager.delegate = delegate
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func requestPermissions() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .denied:
            let alertModel = AlertModel(title: StringConstant.locationManagerAlertTitle, message: StringConstant.locationManagerAlertText, cancelButton: StringConstant.cancel, okButton: StringConstant.settigns) {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                }
            }
            alertPresenter.showAlert(alertModel)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func performLocationDependentAction(_ action: ()->()) {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            action()
        case .denied, .notDetermined:
            requestPermissions()
        default:
            break
        }
    }
}
