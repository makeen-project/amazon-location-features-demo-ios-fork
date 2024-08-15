//
//  MapStyleTypes.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

enum MapStyleImages: Codable  {
    case light, dark, vlight, vdark, llight, ldark, hybrid, satellite
    
    var mapName: String {
        switch self {
        case .light:
            return "StandardLight"
        case .dark:
            return "StandardDark"
        case .vlight:
            return "VisualizationLight"
        case .vdark:
            return "VisualizationDark"
        case .llight:
            return"LogisticsLight"
        case .ldark:
            return "LogisticsDark"
        case .hybrid:
            return "Hybrid"
        case .satellite:
            return "Satellite"
        }
    }
    
    var sourceType: MapStyleSourceType {
        switch self {
        case .light, .dark, .vlight, .vdark, .llight, .ldark, .hybrid, .satellite:
            return .esri
        }
    }
}

enum MapStyleSourceType: String, Codable {
    case esri, here
    
    var title: String {
        switch self {
        case .esri:
            return "Esri"
        case .here:
            return "HERE"
        }
    }
}
