//
//  NavigationPresentation.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSGeoRoutes

struct NavigationPresentation {
    var id: Int
    var vehicleStep: GeoRoutesClientTypes.RouteVehicleTravelStep?
    var pedestrianStep: GeoRoutesClientTypes.RoutePedestrianTravelStep?
    var ferryStep: GeoRoutesClientTypes.RouteFerryTravelStep?
}


