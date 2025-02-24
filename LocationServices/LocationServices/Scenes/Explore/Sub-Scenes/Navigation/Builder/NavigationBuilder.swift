//
//  NavigationBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import AWSGeoRoutes

final class NavigationBuilder {
    static func create(route: GeoRoutesClientTypes.Route, firstDestination: MapModel?, secondDestination: MapModel?) -> NavigationVC {
        let vc = NavigationVC()
        let serivce = LocationService()
        let vm = NavigationVCViewModel(service: serivce, route: route, firstDestination: firstDestination, secondDestination: secondDestination)
        vc.viewModel = vm
        return vc
    }
}
