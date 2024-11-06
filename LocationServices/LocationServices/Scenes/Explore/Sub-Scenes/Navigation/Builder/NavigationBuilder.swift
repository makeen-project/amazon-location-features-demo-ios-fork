//
//  NavigationBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class NavigationBuilder {
    static func create(routeLegDetails: [RouteLegDetails], summaryData: (totalDistance: Double, totalDuration: Double), firstDestination: MapModel?, secondDestination: MapModel?) -> NavigationVC {
        let vc = NavigationVC()
        let serivce = LocationService()
        let vm = NavigationVCViewModel(service: serivce, routeLegDetails: routeLegDetails, summaryData: summaryData, firstDestination: firstDestination, secondDestination: secondDestination)
        vc.viewModel = vm
        return vc
    }
}
