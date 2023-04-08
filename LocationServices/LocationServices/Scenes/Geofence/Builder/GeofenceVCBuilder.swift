//
//  GeofenceVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class GeofenceBuilder {
    static func create() -> GeofenceVC {
        let controller = GeofenceVC()
        let geofenceService = GeofenceAPIService()
        let viewModel = GeofenceViewModel(geofenceService: geofenceService)
        controller.viewModel = viewModel
        return controller
    }
}
