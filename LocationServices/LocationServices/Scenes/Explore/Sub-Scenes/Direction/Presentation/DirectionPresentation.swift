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
    let travelMode: GeoRoutesClientTypes.RouteTravelMode
    let distance: Double
    let duration: Double
    var routeLegDetails: [RouteLegDetails]? = nil
    
    init(model: GeoRoutesClientTypes.Route, travelMode: GeoRoutesClientTypes.RouteTravelMode) throws {
        self.distance = Double(model.summary?.distance ?? 0)
        self.duration = Double(model.summary?.duration  ?? 0)


        self.travelMode = travelMode
        
        if let legs = model.legs {
            self.routeLegDetails = []
            for leg in legs {
                if let legDetails = leg.pedestrianLegDetails {
                    var legDetails = RouteLegDetails(model: legDetails)
                    try legDetails.setLineString(leg: leg)
                    routeLegDetails?.append(legDetails)
                }
                if let legDetails = leg.vehicleLegDetails {
                    var legDetails = RouteLegDetails(model: legDetails)
                    try legDetails.setLineString(leg: leg)
                    routeLegDetails?.append(legDetails)
                }
                if let legDetails = leg.ferryLegDetails {
                    var legDetails = RouteLegDetails(model: legDetails)
                    try legDetails.setLineString(leg: leg)
                    routeLegDetails?.append(legDetails)
                }
            }
        }
    }
}

struct RouteLegDetails {
    let distance: Double
    let duration: Double
    let navigationSteps: [RouteNavigationStep]
    var lineString: GeoData? = nil
    
    init(model: GeoRoutesClientTypes.RouteVehicleLegDetails) {
        self.distance = Double(model.summary?.overview?.distance ?? 0)
        self.duration = Double(model.summary?.overview?.duration ?? 0)
        self.navigationSteps = model.travelSteps?.map({ step in
            return RouteNavigationStep(distance: Double(step.distance), duration: Double(step.duration), instruction: step.instruction ?? "", type: NavigationStepType(from: step.type ?? .sdkUnknown("")))
        }) ?? []
    }
    
    init(model: GeoRoutesClientTypes.RoutePedestrianLegDetails) {
        self.distance = Double(model.summary?.overview?.distance ?? 0)
        self.duration = Double(model.summary?.overview?.duration ?? 0)
        self.navigationSteps = model.travelSteps?.map({ step in
            return RouteNavigationStep(distance: Double(step.distance), duration: Double(step.duration), instruction: step.instruction ?? "", type: NavigationStepType(from: step.type ?? .sdkUnknown("")))
        }) ?? []
    }
    
    init(model: GeoRoutesClientTypes.RouteFerryLegDetails) {
        self.distance = Double(model.summary?.overview?.distance ?? 0)
        self.duration = Double(model.summary?.overview?.duration ?? 0)
        self.navigationSteps = model.travelSteps?.map({ step in
            return RouteNavigationStep(distance: Double(step.distance), duration: Double(step.duration), instruction: step.instruction ?? "", type: NavigationStepType(from: step.type ?? .sdkUnknown("")))
        }) ?? []
    }
    
    mutating func setLineString(leg: GeoRoutesClientTypes.RouteLeg) throws {
        let geometry = Geometry(type: "LineString", coordinates: leg.geometry?.lineString)
        let properties = Properties(name: "Polyline")
        let feature = [Feature(type: "Feature", properties: properties, geometry: geometry)]
        self.lineString = GeoData(type: "FeatureCollection", features: feature)
    }
}

struct RouteNavigationStep {
    let startPosition: [Double]? = nil
    let endPosition: [Double]? = nil
    let distance: Double
    let duration: Double
    let instruction: String
    let type: NavigationStepType
}

enum NavigationStepType {
        case arrive
        case `continue`
        case depart
        case exit
        case keep
        case ramp
        case roundaboutEnter
        case roundaboutExit
        case roundaboutPass
        case turn
        case uTurn
        case sdkUnkown
        case continueHighway
        case enterHighway
    
    // TO DO: replace image names with correct names in future
    var image: UIImage? {
        var imageName = "step-icon"
            switch self {
            case .arrive:
                imageName = "step-icon"
            case .continue:
                imageName = "step-icon"
            case .depart:
                imageName = "step-icon"
            case .exit:
                imageName = "step-icon"
            case .keep:
                imageName = "step-icon"
            case .ramp:
                imageName = "step-icon"
            case .roundaboutEnter:
                imageName = "step-icon"
            case .roundaboutExit:
                imageName = "step-icon"
            case .roundaboutPass:
                imageName = "step-icon"
            case .turn:
                imageName = "step-icon"
            case .uTurn:
                imageName = "step-icon"
            case .continueHighway:
                imageName = "step-icon"
            case .sdkUnkown:
                imageName = "step-icon"
            case .enterHighway:
                imageName = "step-icon"
            }
        return UIImage(named: imageName)
    }
    
    init(from type: GeoRoutesClientTypes.RoutePedestrianTravelStepType) {
        switch type {
        case .arrive:
            self = .arrive
        case .continue:
            self = .continue
        case .depart:
            self = .depart
        case .exit:
            self = .exit
        case .keep:
            self = .keep
        case .ramp:
            self = .ramp
        case .roundaboutEnter:
            self = .roundaboutEnter
        case .roundaboutExit:
            self = .roundaboutExit
        case .roundaboutPass:
            self = .roundaboutPass
        case .turn:
            self = .turn
        case .uTurn:
            self = .uTurn
            
        case .sdkUnknown(_):
            self = .sdkUnkown
        }
    }
    
    init(from type: GeoRoutesClientTypes.RouteVehicleTravelStepType) {
        switch type {
        case .arrive:
            self = .arrive
        case .continue:
            self = .continue
        case .depart:
            self = .depart
        case .exit:
            self = .exit
        case .keep:
            self = .keep
        case .ramp:
            self = .ramp
        case .roundaboutEnter:
            self = .roundaboutEnter
        case .roundaboutExit:
            self = .roundaboutExit
        case .roundaboutPass:
            self = .roundaboutPass
        case .turn:
            self = .turn
        case .uTurn:
            self = .uTurn
        case .sdkUnknown(_):
            self = .sdkUnkown
        case .continueHighway:
            self = .continueHighway
        case .enterHighway:
            self = .enterHighway
        }
    }
    
    init(from type: GeoRoutesClientTypes.RouteFerryTravelStepType) {
        switch type {
        case .arrive:
            self = .arrive
        case .continue:
            self = .continue
        case .depart:
            self = .depart
        case .sdkUnknown(_):
            self = .sdkUnkown
        }
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

