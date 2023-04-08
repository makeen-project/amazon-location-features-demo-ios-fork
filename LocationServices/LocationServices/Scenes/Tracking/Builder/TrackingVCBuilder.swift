//
//  TrackingVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class TrackingVCBuilder {
    
    static func create() -> TrackingVC {
        let controller = TrackingVC()
        let trackingService = TrackingAPIService()
        let geofenceService = GeofenceAPIService()
        let vm = TrackingViewModel(trackingService: trackingService, geofenceService: geofenceService)
        controller.viewModel = vm
        return controller
    }
}
