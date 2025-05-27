//
//  RegionSceneBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class RegionSceneBuilder {
    static func create() -> RegionVC {
        let controller = RegionVC()
        let vm = RegionSceneViewModel()
        controller.viewModel = vm
        return controller
    }
}
