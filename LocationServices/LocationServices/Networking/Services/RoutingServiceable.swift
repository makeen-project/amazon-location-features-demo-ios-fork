//
//  RoutingServiceable.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSLocation

protocol RoutingServiceable {
    func calculateRouteWith(depaturePosition: CLLocationCoordinate2D,
                            destinationPosition: CLLocationCoordinate2D,
                            travelModes: [LocationClientTypes.TravelMode],
                            avoidFerries: Bool,
                            avoidTolls: Bool) async throws -> [LocationClientTypes.TravelMode: Result<DirectionPresentation, Error>]
}

struct RoutingAPIService: AWSRoutingServiceProtocol, RoutingServiceable {
    
    func calculateRouteWith(depaturePosition: CLLocationCoordinate2D,
                            destinationPosition: CLLocationCoordinate2D,
                            travelModes: [LocationClientTypes.TravelMode],
                            avoidFerries: Bool,
                            avoidTolls: Bool) async throws -> [LocationClientTypes.TravelMode: Result<DirectionPresentation, Error>] {
        
        var presentationObject: [LocationClientTypes.TravelMode: Result<DirectionPresentation, Error>] = [:]
        
        for travelMode in travelModes {
            do {
                let response = try await calculateRoute(depaturePosition: depaturePosition,
                                                        destinationPosition: destinationPosition,
                                                        travelMode: travelMode,
                                                        avoidFerries: avoidFerries,
                                                        avoidTolls: avoidTolls)!
                let model = DirectionPresentation(model: response, travelMode: travelMode)
                presentationObject[travelMode] = .success(model)
            } catch {
                presentationObject[travelMode] = .failure(error)
            }
        }
        return presentationObject
    }
}
