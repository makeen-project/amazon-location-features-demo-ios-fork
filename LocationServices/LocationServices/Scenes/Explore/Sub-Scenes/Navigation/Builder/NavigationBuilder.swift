//
//  NavigationBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class NavigationBuilder {
    static func create(steps: [NavigationSteps], summaryData: (totalDistance: Double, totalDuration: Double), firstDestionation: MapModel?, secondDestionation: MapModel?) -> NavigationVC {
        let vc = NavigationVC()
        let serivce = LocationService()
        let vm = NavigationVCViewModel(service: serivce, steps: steps, summaryData: summaryData, firstDestionation: firstDestionation, secondDestionation: secondDestionation)
        vc.viewModel = vm
        return vc
    }
}
