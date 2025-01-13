//
//  ArrivalCardVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import CoreLocation

final class ArrivalCardVCBuilder {
    static func create(route: RouteModel) -> ArrivalCardVC {
        let vc = ArrivalCardVC()
        let vm = ArrivalCardViewModel(route: route)
        vc.viewModel = vm
        return vc
    }
}
