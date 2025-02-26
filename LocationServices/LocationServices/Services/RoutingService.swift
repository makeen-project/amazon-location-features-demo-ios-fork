//
//  RoutingService.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSGeoRoutes

protocol AWSRoutingServiceProtocol {
    func calculateRoute(depaturePosition: CLLocationCoordinate2D,
                        destinationPosition: CLLocationCoordinate2D,
                        travelMode: GeoRoutesClientTypes.RouteTravelMode,
                        avoidFerries: Bool,
                        avoidTolls: Bool,
                        avoidUturns: Bool,
                        avoidTunnels: Bool,
                        avoidDirtRoads: Bool,
                        departNow: Bool?,
                        departureTime: Date?,
                        arrivalTime: Date?) async throws -> CalculateRoutesOutput?
}

extension AWSRoutingServiceProtocol {
    func calculateRoute(depaturePosition: CLLocationCoordinate2D,
                        destinationPosition: CLLocationCoordinate2D,
                        travelMode: GeoRoutesClientTypes.RouteTravelMode,
                        avoidFerries: Bool,
                        avoidTolls: Bool,
                        avoidUturns: Bool,
                        avoidTunnels: Bool,
                        avoidDirtRoads: Bool,
                        departNow: Bool?,
                        departureTime: Date?,
                        arrivalTime: Date?) async throws -> CalculateRoutesOutput? {
        var routeAvoidanceOptions: GeoRoutesClientTypes.RouteAvoidanceOptions? = nil
        if travelMode == .car || travelMode == .truck {
            routeAvoidanceOptions = GeoRoutesClientTypes.RouteAvoidanceOptions(dirtRoads: avoidDirtRoads, ferries: avoidFerries, tollRoads: avoidTolls, tunnels: avoidTunnels, uTurns: avoidUturns)
        }
        else {
            routeAvoidanceOptions = GeoRoutesClientTypes.RouteAvoidanceOptions(dirtRoads: avoidDirtRoads, ferries: avoidFerries, tollRoads: avoidTolls, tunnels: avoidTunnels)
        }
        let origin = [depaturePosition.longitude, depaturePosition.latitude]
        let destination = [destinationPosition.longitude, destinationPosition.latitude]
        let legAdditionalFeatures: [GeoRoutesClientTypes.RouteLegAdditionalFeature] = [.travelStepInstructions, .summary]
        var departNow = departNow
        if departureTime != nil || arrivalTime != nil {
            departNow = nil
        }
        let measureUnit = UnitHelper.getResolvedUnit() == .imperial ? GeoRoutesClientTypes.MeasurementSystem.imperial : GeoRoutesClientTypes.MeasurementSystem.metric
        let input = CalculateRoutesInput(arrivalTime: arrivalTime?.convertDateToIsoString(), avoid: routeAvoidanceOptions, departNow: departNow, departureTime: departureTime?.convertDateToIsoString(), destination: destination, instructionsMeasurementSystem: measureUnit, legAdditionalFeatures: legAdditionalFeatures, legGeometryFormat: .flexiblePolyline, maxAlternatives: 0, origin: origin, travelMode: travelMode, travelStepType: .default)
        
        if let client = AmazonLocationClient.getRoutesClient() {
            let result = try await client.calculateRoutes(input: input)
            return result
        } else {
            return nil
        }
    }
}
