//
//  ExploreMapStyleBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class ExploreMapStyleBuilder {
    static func create() -> ExploreMapStyleVC {
        let controller = ExploreMapStyleVC()
        let viewModel = ExploreMapStyleViewModel()
        controller.viewModel = viewModel
        return controller
    }
}
