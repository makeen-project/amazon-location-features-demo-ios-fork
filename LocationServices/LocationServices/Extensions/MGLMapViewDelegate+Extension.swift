//
//  MGLMapViewDelegate+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import Mapbox

extension MGLMapViewDelegate where Self: NavigationMapProtocol {
    func mapViewMode(_ mapView: MGLMapView?) -> MapMode {
        return mapMode
    }
}
