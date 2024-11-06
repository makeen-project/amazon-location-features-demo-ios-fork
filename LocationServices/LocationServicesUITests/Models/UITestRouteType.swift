//
//  UITestRouteType.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

enum RouteType {
    case pedestrian, car, truck
    
    var containerId: String {
        switch self {
        case .pedestrian:
            return ViewsIdentifiers.Routing.pedestrianContainer
        case .car:
            return ViewsIdentifiers.Routing.carContainer
        case .truck:
            return ViewsIdentifiers.Routing.truckContainer
        }
    }
}
