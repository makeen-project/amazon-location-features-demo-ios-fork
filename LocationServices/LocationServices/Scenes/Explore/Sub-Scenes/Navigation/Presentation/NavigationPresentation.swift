//
//  NavigationPresentation.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSGeoRoutes
import UIKit

struct NavigationPresentation {
    var id: Int
    var vehicleStep: GeoRoutesClientTypes.RouteVehicleTravelStep?
    var pedestrianStep: GeoRoutesClientTypes.RoutePedestrianTravelStep?
    var ferryStep: GeoRoutesClientTypes.RouteFerryTravelStep?
    
    func getStepImage() -> UIImage? {
        if let ferryStep {
            return ferryStep.image
        }
        else if let pedestrianStep {
            return pedestrianStep.image
        }
        else if let vehicleStep {
            return vehicleStep.image
        }
        return nil
    }
    
}


