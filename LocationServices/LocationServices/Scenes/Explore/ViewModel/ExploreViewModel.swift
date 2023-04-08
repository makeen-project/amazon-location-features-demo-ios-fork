//
//  ExploreViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation

import AWSMobileClientXCF
import AWSLocationXCF

final class ExploreViewModel: ExploreViewModelProtocol {
    
    private let routingService: RoutingAPIService
    private var selectedRoute: RouteModel?
    
    var delegate: ExploreViewModelOutputDelegate?
    
    var awsLoginService: AWSLoginService! {
        didSet {
            awsLoginService.delegate = self
        }
    }
    let locationService: LocationService
    
    init(routingService: RoutingAPIService, locationService: LocationService) {
        self.routingService = routingService
        self.locationService = locationService
    }
    
    func activateRoute(route: RouteModel) {
        selectedRoute = route
    }
    
    func deactivateRoute() {
        selectedRoute = nil
    }
    
    func userLocationChanged(_ userLocation: CLLocationCoordinate2D) {
        guard let selectedRoute else { return }
        
        let distanceToDestination = selectedRoute.destinationPosition.distance(from: userLocation)
        guard distanceToDestination > 10 else {
            let mapModel = MapModel(placeName: selectedRoute.destinationPlaceName, placeAddress: selectedRoute.destinationPlaceAddress, placeLat: selectedRoute.destinationPosition.latitude, placeLong: selectedRoute.destinationPosition.longitude)
            delegate?.userReachedDestination(mapModel)
            return
        }
        
        let distanceChanges = selectedRoute.departurePosition.distance(from: userLocation)
        guard distanceChanges > 15 else { return }
        
        reCalculateRoute(with: userLocation)
    }
    
    func reCalculateRoute(with userLocation: CLLocationCoordinate2D) {
        guard let selectedRoute else { return }
        self.selectedRoute?.departurePosition = userLocation
        
        let travelMode = AWSLocationTravelMode(routeType: selectedRoute.travelMode) ?? .walking
        let travelModes = [travelMode]
        routingService.calculateRouteWith(depaturePosition: userLocation,
                                          destinationPosition: selectedRoute.destinationPosition,
                                          travelModes: travelModes,
                                          avoidFerries: selectedRoute.avoidFerries,
                                          avoidTolls: selectedRoute.avoidTolls) { [weak self] response in
            guard let result = response[travelMode] else { return }
            
            switch result {
            case .success(let route):
                self?.delegate?.routeReCalculated(route: route, departureLocation: userLocation, destinationLocation: selectedRoute.destinationPosition, routeType: selectedRoute.travelMode)
            case .failure(let error):
                let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                self?.delegate?.showAlert(model)
            }
            
            
        }
    }
    
    func login() {
        awsLoginService.login()
    }
    
    func logout() {
        awsLoginService.logout()
    }
    
    func loadPlace(for coordinates: CLLocationCoordinate2D, userLocation: CLLocationCoordinate2D?) {
        locationService.searchWithPosition(text: [NSNumber(value: coordinates.longitude), NSNumber(value: coordinates.latitude)], userLat: userLocation?.latitude, userLong: userLocation?.longitude) { [weak self] response in
            switch response {
            case .success(let results):
                guard let result = results.first else { break }
                DispatchQueue.main.async {
                    self?.delegate?.showAnnotation(model: result)
                }
            case .failure(let error):
                let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                DispatchQueue.main.async {
                    self?.delegate?.showAlert(model)
                }
            }
        }
    }
    
    func shouldShowWelcome() -> Bool {
        let welcomeShownVersion = UserDefaultsHelper.get(for: String.self, key: .termsAndConditionsAgreedVersion)
        let currentVersion = UIApplication.appVersion()
        return welcomeShownVersion != currentVersion
    }
}

extension ExploreViewModel: AWSLoginServiceOutputProtocol {
    func loginResult(_ user: AWSUserModel?, error: Error?) {
        guard let user = user else { return }
        let presentation = ExplorePresentation(model: user)
        UserDefaultsHelper.save(value: presentation.userInitial, key: .userInitial)
        delegate?.loginCompleted(presentation)
    }
    
    func logoutResult(_ error: Error?) {
        delegate?.logoutCompleted()
        print("Logout Successfully")
    }
}
