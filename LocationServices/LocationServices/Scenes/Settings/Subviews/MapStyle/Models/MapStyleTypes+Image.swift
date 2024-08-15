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
        case .dark:
            return .dark_gray_map_layer
        case .vlight:
            return .navigationMapLayer
        case .vdark:
            return .contrastMapLayer
        case .llight:
            return .exploreMapLayer
        case .ldark:
            return .light_gray_map_layer
        case .hybrid:
            return .hybird_map_layer
        case .satellite:
            return .esri_imagerey
        }
    }
}
