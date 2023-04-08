//
//  MGLCoordinateBounds+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import Mapbox

extension MGLCoordinateBounds {
    static func create(from: [CLLocationCoordinate2D]) -> MGLCoordinateBounds {
        guard let firstLocation = from.first else { return .init() }
        
        var north: CGFloat = firstLocation.latitude
        var south: CGFloat = firstLocation.latitude
        var west: CGFloat = firstLocation.longitude
        var east: CGFloat = firstLocation.longitude
        
        from.forEach { location in
            if location.latitude < south {
                south = location.latitude
            }
            if location.latitude > north {
                north = location.latitude
            }
            if location.longitude < west {
                west = location.longitude
            }
            if location.longitude > east {
                east = location.longitude
            }
        }
        
        let swBoundLocation = CLLocationCoordinate2D(latitude: south, longitude: west)
        let neBoundLocation = CLLocationCoordinate2D(latitude: north, longitude: east)
        
        let coordinateBounds = MGLCoordinateBounds(sw: swBoundLocation, ne: neBoundLocation)
        
        return coordinateBounds
    }
}
