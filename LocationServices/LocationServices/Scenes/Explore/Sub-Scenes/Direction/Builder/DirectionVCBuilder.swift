//
//  DirectionVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class DirectionVCBuilder {
    static func create() -> DirectionVC {
        let service = LocationService()
        let routingService = RoutingAPIService()
        let vm = DirectionViewModel(service: service, routingService: routingService)
        let vc = DirectionVC()
        vc.viewModel = vm
        return vc
    }
}
