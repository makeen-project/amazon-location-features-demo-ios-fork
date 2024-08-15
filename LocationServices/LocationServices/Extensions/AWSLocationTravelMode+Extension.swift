//
//  AWSLocationTravelMode+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocation

extension LocationClientTypes.TravelMode {
    init?(routeType: RouteTypes) {
        switch routeType {
        case .walking:
            self = .walking
        case .car:
            self = .car
        case .truck:
            self = .truck
        }
    }
}
