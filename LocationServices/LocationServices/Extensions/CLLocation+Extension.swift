//
//  CLLocation+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation

extension CLLocation {
    convenience init(location: CLLocationCoordinate2D) {
        self.init(latitude: location.latitude, longitude: location.longitude)
    }
}
