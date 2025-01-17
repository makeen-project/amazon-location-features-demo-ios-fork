//
//  RoutingServiceable.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSGeoRoutes

protocol RoutingServiceable {
    func calculateRouteWith(depaturePosition: CLLocationCoordinate2D,
                            destinationPosition: CLLocationCoordinate2D,
                            travelModes: [GeoRoutesClientTypes.RouteTravelMode],
                            avoidFerries: Bool,
                            avoidTolls: Bool,
                            avoidUturns: Bool,
                            avoidTunnels: Bool,
                            avoidDirtRoads: Bool,
                            departNow: Bool?,
                            departureTime: Date?,
                            arrivalTime: Date?) async throws -> [GeoRoutesClientTypes.RouteTravelMode: Result<DirectionPresentation, Error>]
}

enum RouteError: Error {
    case noRouteFound(String)
}

struct RoutingAPIService: AWSRoutingServiceProtocol, RoutingServiceable {
    func calculateRouteWith(depaturePosition: CLLocationCoordinate2D,
                            destinationPosition: CLLocationCoordinate2D,
                            travelModes: [GeoRoutesClientTypes.RouteTravelMode],
                            avoidFerries: Bool,
                            avoidTolls: Bool,
                            avoidUturns: Bool,
                            avoidTunnels: Bool,
                            avoidDirtRoads: Bool,
                            departNow: Bool?,
                            departureTime: Date?,
                            arrivalTime: Date?) async throws -> [GeoRoutesClientTypes.RouteTravelMode: Result<DirectionPresentation, Error>] {
        
        var presentationObject: [GeoRoutesClientTypes.RouteTravelMode: Result<DirectionPresentation, Error>] = [:]
        
        for travelMode in travelModes {
            do {
                let response = try await calculateRoute(depaturePosition: depaturePosition,
                                                        destinationPosition: destinationPosition,
                                                        travelMode: travelMode,
                                                        avoidFerries: avoidFerries,
                                                        avoidTolls: avoidTolls,
                                                        avoidUturns: avoidUturns,
                                                        avoidTunnels: avoidTunnels,
                                                        avoidDirtRoads: avoidDirtRoads,
                                                        departNow: departNow,
                                                        departureTime: departureTime,
                                                        arrivalTime: arrivalTime)
                if let route = response?.routes?[safe: 0] {
                    let model = DirectionPresentation(route: route, travelMode: travelMode)
                    presentationObject[travelMode] = .success(model)
                }
                else {
                    presentationObject[travelMode] = .failure(RouteError.noRouteFound("No routes found"))
                }
            } catch {
                presentationObject[travelMode] = .failure(error)
            }
        }
        return presentationObject
    }
}
