//
//  RoutingServiceable.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSLocationXCF

protocol RoutingServiceable {
    func calculateRouteWith(depaturePosition: CLLocationCoordinate2D,
                            destinationPosition: CLLocationCoordinate2D,
                            travelModes: [AWSLocationTravelMode],
                            avoidFerries: Bool,
                            avoidTolls: Bool,
                            completion: @escaping (([AWSLocationTravelMode: Result<DirectionPresentation, Error>]) -> Void))
}

struct RoutingAPIService: AWSRoutingServiceProtocol, RoutingServiceable {
    func calculateRouteWith(depaturePosition: CLLocationCoordinate2D,
                            destinationPosition: CLLocationCoordinate2D,
                            travelModes: [AWSLocationTravelMode],
                            avoidFerries: Bool,
                            avoidTolls: Bool,
                            completion: @escaping (([AWSLocationTravelMode: Result<DirectionPresentation, Error>]) -> Void)) {
        
        var presentationObject: [AWSLocationTravelMode: Result<DirectionPresentation, Error>] = [:]
        
        let group = DispatchGroup()
        
        travelModes.forEach { travelMode in
            group.enter()
            calculateRoute(depaturePosition: depaturePosition,
                           destinationPosition: destinationPosition,
                           travelMode: travelMode,
                           avoidFerries: avoidFerries,
                           avoidTolls: avoidTolls) { response in
                switch response {
                case .success(let result):
                    let model = DirectionPresentation(model: result, travelMode: travelMode)
                    presentationObject[travelMode] = .success(model)
                case .failure(let error):
                    presentationObject[travelMode] = .failure(error)
                }
                
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(presentationObject)
        }
    }
}
