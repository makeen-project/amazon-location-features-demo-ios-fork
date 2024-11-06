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
                        avoidTolls: Bool) async throws -> CalculateRoutesOutput?
}

extension AWSRoutingServiceProtocol {
    func calculateRoute(depaturePosition: CLLocationCoordinate2D,
                        destinationPosition: CLLocationCoordinate2D,
                        travelMode: GeoRoutesClientTypes.RouteTravelMode,
                        avoidFerries: Bool,
                        avoidTolls: Bool) async throws -> CalculateRoutesOutput? {
        var routeAvoidanceOptions: GeoRoutesClientTypes.RouteAvoidanceOptions? = nil
        if travelMode == .car {
            routeAvoidanceOptions = GeoRoutesClientTypes.RouteAvoidanceOptions(ferries: avoidFerries, tollRoads: avoidTolls)
        }
        let origin = [depaturePosition.longitude, depaturePosition.latitude]
        let destination = [destinationPosition.longitude, destinationPosition.latitude]
        let legAdditionalFeatures: [GeoRoutesClientTypes.RouteLegAdditionalFeature] = [.travelStepInstructions, .summary]
        
        let input = CalculateRoutesInput(avoid: routeAvoidanceOptions, departNow: true, destination: destination, instructionsMeasurementSystem: .metric, legAdditionalFeatures: legAdditionalFeatures, legGeometryFormat: GeoRoutesClientTypes.GeometryFormat.simple, origin: origin, travelStepType: .default)
        
        if let client = AmazonLocationClient.getRoutesClient() {
            let result = try await client.calculateRoutes(input: input)
            return result
        } else {
            return nil
        }
    }
}
