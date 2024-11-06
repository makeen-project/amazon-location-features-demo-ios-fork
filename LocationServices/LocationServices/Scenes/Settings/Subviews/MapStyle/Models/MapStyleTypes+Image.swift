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
        case .standard:
            return .streetMapLayer
        case .monochrome:
            return .light_gray_map_layer
        case .hybrid:
            return .hybird_map_layer
        case .satellite:
            return .here_imagerey_map_layer
        }
    }
}
