//
//  RouteOptionBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class RouteOptionBuilder {
    static func create() -> RouteOptionVC {
        let controller = RouteOptionVC()
        let viewModel = RouteOptionViewModel()
        controller.viewModel = viewModel
        return controller
    }
}
