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

extension GeoRoutesClientTypes.RouteVehicleTravelStep {
    var image: UIImage? {
        var imageName = "step-icon"
        switch self.type {
            case .arrive:
                imageName = "depart"
            case .continue:
                imageName = "arrow-up"
            case .depart:
                imageName = "depart"
            case .exit:
            imageName = self.exitStepDetails?.steeringDirection == .right ? "arrow-exit-right": "arrow-exit-left"
            case .keep:
                imageName = "arrow-up"
            case .ramp:
                imageName = self.rampStepDetails?.steeringDirection == .right ? "arrow-ramp-right" : "arrow-ramp-left"
            case .roundaboutEnter:
                imageName = "arrow-roundabout-enter"
            case .roundaboutExit:
                imageName = self.roundaboutExitStepDetails?.steeringDirection == .right ? "arrow-roundabout-exit-right" :"arrow-roundabout-exit-left"
            case .roundaboutPass:
                imageName = self.roundaboutPassStepDetails?.steeringDirection == .right ? "arrow-roundabout-pass-right" : "arrow-roundabout-pass-left"
            case .turn:
                imageName = self.turnStepDetails?.steeringDirection == .right ? "corner-up-right" : "corner-up-left"
            case .uTurn:
                imageName = self.uTurnStepDetails?.steeringDirection == .right ? "arrow-uTurn-right" : "arrow-uTurn-left"
            case .continueHighway:
                imageName = "arrow-up"
            case .enterHighway:
                imageName = self.enterHighwayStepDetails?.steeringDirection == .right ? "arrow-up-right" : "arrow-up-left"
            case .sdkUnknown(_):
                imageName = "step-icon"
            case .none:
                imageName = "step-icon"
            }
        return UIImage(named: imageName)
    }
    
}

extension GeoRoutesClientTypes.RoutePedestrianTravelStep {
    var image: UIImage? {
        var imageName = "step-icon"
        switch self.type {
            case .arrive:
                imageName = "depart"
            case .continue:
                imageName = "arrow-up"
            case .depart:
                imageName = "depart"
            case .keep:
                imageName = "arrow-up"
            case .roundaboutEnter:
                imageName = "arrow-roundabout-enter"
            case .roundaboutExit:
                imageName = self.roundaboutExitStepDetails?.steeringDirection == .right ? "arrow-roundabout-exit-right" :"arrow-roundabout-exit-left"
            case .roundaboutPass:
                imageName = self.roundaboutPassStepDetails?.steeringDirection == .right ? "arrow-roundabout-pass-right" : "arrow-roundabout-pass-left"
            case .turn:
                imageName = self.turnStepDetails?.steeringDirection == .right ? "corner-up-right" : "corner-up-left"
            case .uTurn:
                imageName = self.turnStepDetails?.steeringDirection == .right ? "arrow-uTurn-right" : "arrow-uTurn-left"
            case .sdkUnknown(_):
                imageName = "step-icon"
            case .none:
                imageName = "step-icon"
            case .exit:
                imageName = "arrow-exit-right"
            case .ramp:
                imageName = "arrow-ramp-right"
        }
        return UIImage(named: imageName)
    }
}

extension GeoRoutesClientTypes.RouteFerryTravelStep {
    var image: UIImage? {
        var imageName = "step-icon"
        switch self.type {
        case .none:
            imageName = "step-icon"
        case .some(_):
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

