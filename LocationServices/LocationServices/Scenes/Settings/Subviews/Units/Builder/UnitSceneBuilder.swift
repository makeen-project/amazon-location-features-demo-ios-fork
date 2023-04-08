//
//  UnitSceneBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class UnitSceneBuilder {
    static func create() -> UnitVC {
        let controller = UnitVC()
        let vm = UnitSceneViewModel()
        controller.viewModel = vm
        return controller
    }
}
