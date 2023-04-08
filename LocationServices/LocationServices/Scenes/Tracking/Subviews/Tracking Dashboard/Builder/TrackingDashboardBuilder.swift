//
//  TrackingDashboardBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class TrackingDashboardBuilder {
    static func create() -> TrackingDashboardController {
        let vc = TrackingDashboardController()
        let vm = TrackingDashboarViewModel()
        vc.viewModel = vm
        return vc
    }
}
