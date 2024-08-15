//
//  MLNMapViewDelegate+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import MapLibre

extension MLNMapViewDelegate where Self: NavigationMapProtocol {
    func mapViewMode(_ mapView: MLNMapView?) -> MapMode {
        return mapMode
    }
}
