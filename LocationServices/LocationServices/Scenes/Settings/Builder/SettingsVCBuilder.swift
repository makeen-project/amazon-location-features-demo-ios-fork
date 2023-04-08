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
        let awsLoginService = AWSLoginService()
        let viewModel = SettingsViewModel()
        viewModel.awsLoginService = awsLoginService
        controller.viewModel = viewModel
        return controller
    }
}
