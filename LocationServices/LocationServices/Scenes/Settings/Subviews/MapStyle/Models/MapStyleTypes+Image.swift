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
            return .standardMapLayer
        case .monochrome:
            return .monochromeMapLayer
        case .hybrid:
            return .hybridMapLayer
        case .satellite:
            return .satelliteMapLayer
        }
    }
}
