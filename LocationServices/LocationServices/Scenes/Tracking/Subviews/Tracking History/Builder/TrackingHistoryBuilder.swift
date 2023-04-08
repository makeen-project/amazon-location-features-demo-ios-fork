//
//  TrackingHistoryBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class TrackingHistoryBuilder {
    static func create(isTrackingActive: Bool) -> TrackingHistoryVC {
        let controller = TrackingHistoryVC()
        let service = TrackingAPIService()
        let vm = TrackingHistoryViewModel(serivce: service, isTrackingActive: isTrackingActive)
        controller.viewModel = vm
        return controller
    }
}
