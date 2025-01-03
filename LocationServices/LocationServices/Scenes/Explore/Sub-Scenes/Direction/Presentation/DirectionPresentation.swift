//
//  DirectionPresentation.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSGeoRoutes
import UIKit

struct DirectionPresentation {
    let route: GeoRoutesClientTypes.Route
    let travelMode: GeoRoutesClientTypes.RouteTravelMode
}

extension GeoRoutesClientTypes.RouteVehicleTravelStepType {
    var image: UIImage? {
        var imageName = "step-icon"
            switch self {
            case .arrive:
                imageName = "depart"
            case .continue:
                imageName = "arrow-up"
            case .depart:
                imageName = "depart"
            case .exit:
                imageName = "arrow-exit-right"
            case .keep:
                imageName = "arrow-up"
            case .ramp:
                imageName = "arrow-ramp-right"
            case .roundaboutEnter:
                imageName = "arrow-roundabout-enter"
            case .roundaboutExit:
                imageName = "arrow-roundabout-exit"
            case .roundaboutPass:
                imageName = "arrow-roundabout-pass"
            case .turn:
                imageName = "corner-up-right"
            case .uTurn:
                imageName = "arrow-uTurn-right"
            case .continueHighway:
                imageName = "arrow-up"
            case .enterHighway:
                imageName = "arrow-up"
            case .sdkUnknown(_):
                imageName = "step-icon"
            }
        return UIImage(named: imageName)
    }
    
}

extension GeoRoutesClientTypes.RoutePedestrianTravelStepType {
    var image: UIImage? {
        var imageName = "step-icon"
            switch self {
            case .arrive:
                imageName = "depart"
            case .continue:
                imageName = "arrow-up"
            case .depart:
                imageName = "depart"
            case .exit:
                imageName = "arrow-exit-right"
            case .keep:
                imageName = "arrow-up"
            case .ramp:
                imageName = "arrow-ramp-right"
            case .roundaboutEnter:
                imageName = "arrow-roundabout-enter"
            case .roundaboutExit:
                imageName = "arrow-roundabout-exit"
            case .roundaboutPass:
                imageName = "arrow-roundabout-pass"
            case .turn:
                imageName = "corner-up-right"
            case .uTurn:
                imageName = "arrow-uTurn-right"
            case .sdkUnknown(_):
                imageName = "step-icon"
            }
        return UIImage(named: imageName)
    }
}

// MARK: - GeoData
struct GeoData: Codable {
    let type: String
    let features: [Feature]
}

// MARK: - Feature
struct Feature: Codable {
    let type: String
    let properties: Properties
    let geometry: Geometry
}

// MARK: - Geometry
struct Geometry: Codable {
    let type: String
    let coordinates: [[Double]]?
}

// MARK: - Properties
struct Properties: Codable {
    let name: String
}

