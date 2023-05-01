//
//  RoutingAPIServiceMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0


import Foundation
@testable import LocationServices
import AWSLocationXCF
import CoreLocation

class RoutingAPIServiceMock: RoutingServiceable {
    var putResult: [AWSLocationTravelMode: Result<LocationServices.DirectionPresentation, Error>]?
    
    let delay: TimeInterval
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func calculateRouteWith(depaturePosition: CLLocationCoordinate2D, destinationPosition: CLLocationCoordinate2D, travelModes: [AWSLocationTravelMode], avoidFerries: Bool, avoidTolls: Bool, completion: @escaping (([AWSLocationTravelMode : Result<LocationServices.DirectionPresentation, Error>]) -> Void)) {
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
