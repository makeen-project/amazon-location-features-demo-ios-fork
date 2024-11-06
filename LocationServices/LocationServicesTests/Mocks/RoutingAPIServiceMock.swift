//
//  RoutingAPIServiceMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0


import Foundation
@testable import LocationServices
import AWSGeoRoutes
import CoreLocation

class RoutingAPIServiceMock: RoutingServiceable {
    func calculateRouteWith(depaturePosition: CLLocationCoordinate2D, destinationPosition: CLLocationCoordinate2D, travelModes: [GeoRoutesClientTypes.RouteTravelMode], avoidFerries: Bool, avoidTolls: Bool) async throws -> [GeoRoutesClientTypes.RouteTravelMode : Result<LocationServices.DirectionPresentation, any Error>] {
            let result = self.putResult
            return result!
    }
    
    var putResult: [GeoRoutesClientTypes.RouteTravelMode: Result<LocationServices.DirectionPresentation, Error>]?
    
    let delay: TimeInterval
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func calculateRouteWith(depaturePosition: CLLocationCoordinate2D, destinationPosition: CLLocationCoordinate2D, travelModes: [GeoRoutesClientTypes.RouteTravelMode], avoidFerries: Bool, avoidTolls: Bool, completion: @escaping (([GeoRoutesClientTypes.RouteTravelMode : Result<LocationServices.DirectionPresentation, Error>]) -> Void)) {
        perform { [weak self] in
            guard let result = self?.putResult else { return }
            completion(result)
        }
    }
    
    private func perform(action: @escaping ()->()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            action()
        }
    }
    
}
