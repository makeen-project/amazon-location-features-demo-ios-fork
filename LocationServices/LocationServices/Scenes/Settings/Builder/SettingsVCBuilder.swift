//
//  SettingsVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SettingsVCBuilder {
    static func create() -> SettingsVC {
        let controller = SettingsVC()
        let viewModel = SettingsViewModel()
        controller.viewModel = viewModel
        return controller
    }
}
