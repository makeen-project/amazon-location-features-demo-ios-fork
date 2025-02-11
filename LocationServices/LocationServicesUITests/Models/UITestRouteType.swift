//
//  UITestRouteType.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

enum RouteType {
    case pedestrian, car, truck, scooter
    
    var containerId: String {
        switch self {
        case .pedestrian:
            return ViewsIdentifiers.Routing.pedestrianContainer
        case .scooter:
            return ViewsIdentifiers.Routing.scooterContainer
        case .car:
            return ViewsIdentifiers.Routing.carContainer
        case .truck:
            return ViewsIdentifiers.Routing.truckContainer
        }
    }
    
    var title: String {
        switch self {
        case .pedestrian:
            return "Pedestrian"
        case .scooter:
            return "Scooter"
        case .car:
            return "Car"
        case .truck:
            return "Truck"
        }
    }
}
