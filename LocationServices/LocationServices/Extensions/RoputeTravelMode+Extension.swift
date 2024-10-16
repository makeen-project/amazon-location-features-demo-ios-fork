//
//  AWSLocationTravelMode+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSGeoRoutes

extension GeoRoutesClientTypes.RouteTravelMode {
    init?(routeType: RouteTypes) {
        switch routeType {
        case .pedestrian:
            self = .pedestrian
        case .car:
            self = .car
        case .truck:
            self = .truck
        }
    }
}
