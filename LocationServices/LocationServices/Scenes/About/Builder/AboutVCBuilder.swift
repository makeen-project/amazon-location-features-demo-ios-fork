//
//  AboutVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class AboutVCBuilder {
    static func create() -> AboutVC {
        let viewModel = AboutViewModel()
        let controller = AboutVC()
        controller.viewModel = viewModel
        return controller
    }
}
