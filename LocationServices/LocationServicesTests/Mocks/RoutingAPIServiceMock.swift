//
//  RoutingAPIServiceMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0


import Foundation
@testable import LocationServices
import AWSLocation
import CoreLocation

class RoutingAPIServiceMock: RoutingServiceable {
    func calculateRouteWith(depaturePosition: CLLocationCoordinate2D, destinationPosition: CLLocationCoordinate2D, travelModes: [AWSLocation.LocationClientTypes.TravelMode], avoidFerries: Bool, avoidTolls: Bool) async throws -> [AWSLocation.LocationClientTypes.TravelMode : Result<LocationServices.DirectionPresentation, any Error>] {
            let result = self.putResult
            return result!
    }
    
    var putResult: [LocationClientTypes.TravelMode: Result<LocationServices.DirectionPresentation, Error>]?
    
    let delay: TimeInterval
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func calculateRouteWith(depaturePosition: CLLocationCoordinate2D, destinationPosition: CLLocationCoordinate2D, travelModes: [LocationClientTypes.TravelMode], avoidFerries: Bool, avoidTolls: Bool, completion: @escaping (([LocationClientTypes.TravelMode : Result<LocationServices.DirectionPresentation, Error>]) -> Void)) {
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
