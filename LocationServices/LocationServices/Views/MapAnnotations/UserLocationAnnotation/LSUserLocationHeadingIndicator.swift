//
//  LSUserLocationHeadingIndicator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import Mapbox

protocol LSUserLocationHeadingIndicator: CALayer {
    init(userLocationView: MGLUserLocationAnnotationView)
    
    func updateHeadingAccuracy(_ accuracy: CLLocationDirection)
    func updateTintColor(_ color: CGColor)
}
