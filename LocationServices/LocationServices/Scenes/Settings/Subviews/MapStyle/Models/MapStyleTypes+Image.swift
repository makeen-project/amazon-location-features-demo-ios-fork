//
//  MapStyleTypes+Image.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension MapStyleImages {
    var image: UIImage {
        switch self {
        case .light:
            return .lightMapLayer
        case .street:
            return .streetMapLayer
        case .navigation:
            return .navigationMapLayer
        case .explore:
            return .exploreMapLayer
        case .contrast:
            return .contrastMapLayer
        case .exploreTruck:
            return .explore_truck_map_layer
        case .darkGray:
            return .dark_gray_map_layer
        case .lightGray:
            return .light_gray_map_layer
        case .Imagery:
            return .esri_imagerey
        case .hereImagery:
            return .here_imagerey_map_layer
        case .hybrid:
            return .hybird_map_layer
        }
    }
}
