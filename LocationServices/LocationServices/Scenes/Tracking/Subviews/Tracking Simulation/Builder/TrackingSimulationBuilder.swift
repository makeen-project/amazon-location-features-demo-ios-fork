//
//  TrackingSimulationBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class TrackingSimulationBuilder {
    static func create() -> TrackingSimulationController {
        let controller = TrackingSimulationController()
        let service = TrackingAPIService()
        let vm = TrackingHistoryViewModel(serivce: service, isTrackingActive: true)
        controller.viewModel = vm
        return controller
    }
}
