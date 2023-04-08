//
//  RoutingService.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocationXCF
import CoreLocation

protocol AWSRoutingServiceProtocol {
    func calculateRoute(depaturePosition: CLLocationCoordinate2D,
                        destinationPosition: CLLocationCoordinate2D,
                        travelMode: AWSLocationTravelMode,
                        avoidFerries: Bool,
                        avoidTolls: Bool,
                        completion: @escaping ((Result<AWSLocationCalculateRouteResponse, Error>) -> Void))
}

extension AWSRoutingServiceProtocol {
    func calculateRoute(depaturePosition: CLLocationCoordinate2D,
                        destinationPosition: CLLocationCoordinate2D,
                        travelMode: AWSLocationTravelMode,
                        avoidFerries: Bool,
                        avoidTolls: Bool,
                        completion: @escaping ((Result<AWSLocationCalculateRouteResponse, Error>) -> Void)) {
        
        let request = AWSLocationCalculateRouteRequest()!
        request.travelMode = travelMode
        request.calculatorName = getCalculatorName()
        request.includeLegGeometry = true
        if travelMode == .car {
            let carModeOptions = AWSLocationCalculateRouteCarModeOptions()
            carModeOptions?.avoidTolls = NSNumber(booleanLiteral: avoidTolls)
            carModeOptions?.avoidFerries = NSNumber(booleanLiteral: avoidFerries)
            request.carModeOptions = carModeOptions
        }
        request.departurePosition = [NSNumber(value: depaturePosition.longitude), NSNumber(value: depaturePosition.latitude)]
        request.destinationPosition = [NSNumber(value: destinationPosition.longitude), NSNumber(value: destinationPosition.latitude)]
        
        let result = AWSLocation(forKey: "default").calculateRoute(request)

        result.continueWith { response in
            if let taskResult = response.result {
                completion(.success(taskResult))
            } else {
                let defaultError = NSError(domain: "Routing", code: -1)
                let error = response.error ?? defaultError
                print("error \(error)")
                completion(.failure(error))
            }
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
