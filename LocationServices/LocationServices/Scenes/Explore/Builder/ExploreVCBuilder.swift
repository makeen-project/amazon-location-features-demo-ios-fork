//
//  ExploreVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class ExploreVCBuilder {
    static func create() -> ExploreVC {
        let controller = ExploreVC()
        let awsLoginService = AWSLoginService()
        let routingService = RoutingAPIService()
        let locationService = LocationService()
        let viewModel = ExploreViewModel(routingService: routingService, locationService: locationService)
        viewModel.awsLoginService = awsLoginService
        controller.viewModel = viewModel
        return controller
    }
}
