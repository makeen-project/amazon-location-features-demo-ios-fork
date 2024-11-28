//
//  ExploreViewModel.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSGeoRoutes
import UIKit

final class ExploreViewModel: ExploreViewModelProtocol {
    
    private let routingService: RoutingServiceable
    private var selectedRoute: RouteModel?
    
    var delegate: ExploreViewModelOutputDelegate?
    
    var awsLoginService: AWSLoginService! {
        didSet {
            awsLoginService.delegate = self
        }
    }
    let locationService: LocationServiceable
    
    init(routingService: RoutingServiceable, locationService: LocationServiceable) {
        self.routingService = routingService
        self.locationService = locationService
    }
    
    func activateRoute(route: RouteModel) {
        selectedRoute = route
    }
    
    func deactivateRoute() {
        selectedRoute = nil
    }
    
    func isSelectedRouteHasValue() -> Bool {
        guard selectedRoute != nil else {
            return false
        }
        return true
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
        
        Task {
            try await reCalculateRoute(with: userLocation)
        }
    }
    
    func reCalculateRoute(with userLocation: CLLocationCoordinate2D) async throws {
        guard let selectedRoute else { return }
        self.selectedRoute?.departurePosition = userLocation
        
        let travelMode = GeoRoutesClientTypes.RouteTravelMode(routeType: selectedRoute.travelMode) ?? .pedestrian
        let travelModes = [travelMode]
        let result = try await routingService.calculateRouteWith(depaturePosition: userLocation,
                                          destinationPosition: selectedRoute.destinationPosition,
                                          travelModes: travelModes,
                                          avoidFerries: selectedRoute.avoidFerries,
                                          avoidTolls: selectedRoute.avoidTolls)
        for route in result {
            self.delegate?.routeReCalculated(route: try route.value.get(), departureLocation: userLocation, destinationLocation: selectedRoute.destinationPosition, routeType: selectedRoute.travelMode)
        }
    }
    
    func login() {
        Task {
            try await awsLoginService.login()
        }
    }
    
    func logout() {
        awsLoginService.logout()
    }
    
    func loadPlace(for coordinates: CLLocationCoordinate2D, userLocation: CLLocationCoordinate2D?) async {
        var biasLocation = userLocation
        if let mapCenter = UserDefaultsHelper.getObject(value: LocationCoordinate2D.self, key: .mapCenter) {
            biasLocation = CLLocationCoordinate2D(latitude: mapCenter.latitude, longitude: mapCenter.longitude)
        }
        let result = await locationService.reverseGeocode(position: [coordinates.longitude, coordinates.latitude], userLat: biasLocation?.latitude, userLong: biasLocation?.longitude)
        do {
            if var model = try result.get().first, let placeId = model.placeId,
               let place = try await locationService.getPlace(with: placeId) {
                model.place = place
                self.delegate?.showAnnotation(model: model, force: false)
            }
        }
        catch {
            let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
            DispatchQueue.main.async {
                self.delegate?.showAlert(model)
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
