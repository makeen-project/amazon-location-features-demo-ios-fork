//
//  DirectionPresentation.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocationXCF

struct DirectionPresentation {
    let travelMode: AWSLocationTravelMode
    let distance: Double
    let duration: Double
    let lineString: GeoData
    let navigationSteps: [NavigationSteps]
    
    
    init(model: AWSLocationCalculateRouteResponse, travelMode: AWSLocationTravelMode) {
        self.distance = Double(model.legs?[0].distance ?? 0)
        self.duration = Double(model.legs?[0].durationSeconds  ?? 0)

        let geometry = Geometry(type: "LineString", coordinates: model.legs?[0].geometry?.lineString as? [[Double]])
        let properties = Properties(name: "Crema to Council Cres")
        let feature = [Feature(type: "Feature", properties: properties, geometry: geometry)]
        self.lineString = GeoData(type: "FeatureCollection", features: feature)
        self.travelMode = travelMode
        
        if let steps = model.legs?[safe: 0]?.steps {
            self.navigationSteps = steps.map(NavigationSteps.init)
        } else {
            self.navigationSteps = []
        }
    }
}


struct NavigationSteps {
    let distance: Double
    let duration: Double
    let startPosition: [Double]
    let endPosition: [Double]
    
    init(model: AWSLocationStep) {
        self.distance = Double(model.distance ?? 0)
        self.duration = Double(model.durationSeconds ?? 0)
        self.startPosition = model.startPosition as? [Double] ?? []
        self.endPosition = model.endPosition as? [Double] ?? []
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

