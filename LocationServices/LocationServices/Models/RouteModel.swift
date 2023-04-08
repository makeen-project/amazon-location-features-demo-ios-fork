//
//  RouteModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation

struct RouteModel {
    var departurePosition: CLLocationCoordinate2D
    let destinationPosition:  CLLocationCoordinate2D
    let travelMode: RouteTypes
    let avoidFerries: Bool
    let avoidTolls: Bool
    
    let isPreview: Bool
    
    let departurePlaceName: String?
    let departurePlaceAddress: String?
    let destinationPlaceName: String?
    let destinationPlaceAddress: String?
}
