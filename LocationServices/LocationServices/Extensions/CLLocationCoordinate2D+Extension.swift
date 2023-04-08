//
//  CLLocationCoordinate2D+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Hashable {
    func distance(from location: CLLocationCoordinate2D) -> CLLocationDistance {
        let currentLocation = CLLocation(location: self)
        let fromLocation = CLLocation(location: location)
        return currentLocation.distance(from: fromLocation)
    }
    
    func isSameLocation(_ location: CLLocationCoordinate2D, accuracy: CLLocationDistance = 0) -> Bool {
        return self.distance(from: location) < accuracy
    }
    
    func isCurrentLocation(_ currentLocation: CLLocationCoordinate2D?) -> Bool {
        guard let currentLocation, CLLocationCoordinate2DIsValid(currentLocation) else { return false }
        return isSameLocation(currentLocation, accuracy: 5)
    }
    
    // MARK: Hashable
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}
