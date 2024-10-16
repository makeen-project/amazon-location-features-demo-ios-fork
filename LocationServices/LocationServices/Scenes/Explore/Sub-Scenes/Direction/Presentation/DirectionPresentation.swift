//
//  DirectionPresentation.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSGeoRoutes

struct DirectionPresentation {
    let travelMode: GeoRoutesClientTypes.RouteTravelMode
    let distance: Double
    let duration: Double
    let lineString: GeoData
    var routeLegDetails: RouteLegDetails? = nil
    
    
    init(model: GeoRoutesClientTypes.Route, travelMode: GeoRoutesClientTypes.RouteTravelMode) {
        self.distance = Double(model.summary?.distance ?? 0)
        self.duration = Double(model.summary?.duration  ?? 0)

        let geometry = Geometry(type: "LineString", coordinates: model.legs?[0].geometry?.lineString as? [[Double]])
        let properties = Properties(name: "Crema to Council Cres")
        let feature = [Feature(type: "Feature", properties: properties, geometry: geometry)]
        self.lineString = GeoData(type: "FeatureCollection", features: feature)
        self.travelMode = travelMode
        
        if let leg = model.legs?[safe: 0] {
            if leg.travelMode == .pedestrian, let legDetails = leg.pedestrianLegDetails {
                self.routeLegDetails = RouteLegDetails(model: legDetails)
            }
            else if let legDetails = leg.vehicleLegDetails {
                self.routeLegDetails = RouteLegDetails(model: legDetails)
            }
        }
    }
}


struct RouteLegDetails {
    let distance: Double
    let duration: Double
    let navigationSteps: [RouteNavigationStep]
    
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
    
    init(from type: GeoRoutesClientTypes.RoutesVehicleTravelStepType) {
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

