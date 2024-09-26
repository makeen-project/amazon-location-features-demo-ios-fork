//
//  RoutingService.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocation
import CoreLocation

protocol AWSRoutingServiceProtocol {
    func calculateRoute(depaturePosition: CLLocationCoordinate2D,
                        destinationPosition: CLLocationCoordinate2D,
                        travelMode: LocationClientTypes.TravelMode,
                        avoidFerries: Bool,
                        avoidTolls: Bool) async throws -> CalculateRouteOutput?
}

extension AWSRoutingServiceProtocol {
    func calculateRoute(depaturePosition: CLLocationCoordinate2D,
                        destinationPosition: CLLocationCoordinate2D,
                        travelMode: LocationClientTypes.TravelMode,
                        avoidFerries: Bool,
                        avoidTolls: Bool) async throws -> CalculateRouteOutput? {
        var carModeOptions: LocationClientTypes.CalculateRouteCarModeOptions? = nil
        if travelMode == .car {
            carModeOptions = LocationClientTypes.CalculateRouteCarModeOptions(avoidFerries: avoidFerries, avoidTolls: avoidTolls)
        }
        let input = CalculateRouteInput(calculatorName: getCalculatorName(), carModeOptions: carModeOptions, departNow: true, departurePosition: [depaturePosition.longitude, depaturePosition.latitude], destinationPosition: [destinationPosition.longitude, destinationPosition.latitude], includeLegGeometry: true, travelMode: travelMode)
        if let client = try await AmazonLocationClient.defaultCognito()?.locationClient {
            let result = try await client.calculateRoute(input: input)
            
            return result
        } else {
            return nil
        }
    }
}

extension AWSRoutingServiceProtocol {
    private func getCalculatorName() -> String {
        let localData = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        switch localData?.type {
        case .esri, .none:
            return DataProviderName.esri.routeCalculator
        case .here:
            return DataProviderName.here.routeCalculator
        }
    }
}
