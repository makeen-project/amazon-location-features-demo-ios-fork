//
//  MapStyleTypes.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

enum MapStyleImages: Codable  {
    case light, street, navigation, explore,contrast,exploreTruck, darkGray, lightGray, Imagery, hereImagery, hybrid
    
    var mapName: String {
        switch self {
        case .light:
            return "location.aws.com.demo.maps.Esri.Light"
        case .street:
            return "location.aws.com.demo.maps.Esri.Streets"
        case .navigation:
            return "location.aws.com.demo.maps.Esri.Navigation"
        case .explore:
            return "location.aws.com.demo.maps.HERE.Explore"
        case .contrast:
            return"location.aws.com.demo.maps.HERE.Contrast"
        case .exploreTruck:
            return "location.aws.com.demo.maps.HERE.ExploreTruck"
        case .darkGray:
            return "location.aws.com.demo.maps.Esri.DarkGrayCanvas"
        case .lightGray:
            return "location.aws.com.demo.maps.Esri.LightGrayCanvas"
        case .Imagery:
            return "location.aws.com.demo.maps.Esri.Imagery"
        case .hereImagery:
            return "location.aws.com.demo.maps.HERE.Imagery"
        case .hybrid:
            return "location.aws.com.demo.maps.HERE.Hybrid"
        }
    }
    
    var sourceType: MapStyleSourceType {
        switch self {
        case .light, .street, .navigation, .darkGray, .lightGray, .Imagery:
            return .esri
        case .explore, .contrast, .exploreTruck, .hereImagery, .hybrid:
            return .here
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
