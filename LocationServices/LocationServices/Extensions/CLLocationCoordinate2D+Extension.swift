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
    
    func location(radius: Double, radians: Double) -> CLLocationCoordinate2D {
        let distRadians = radius / (6372797.6) // earth radius in meters

        let lat1 = latitude * Double.pi / 180
        let lon1 = longitude * Double.pi / 180

        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(radians))
        let lon2 = lon1 + atan2(sin(radians) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))

        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
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

struct LocationCoordinate2D: Codable {
    var latitude: Double
    var longitude: Double
}
