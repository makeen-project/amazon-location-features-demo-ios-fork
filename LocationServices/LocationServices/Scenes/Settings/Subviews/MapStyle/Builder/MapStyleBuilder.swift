//
//  MapStyleBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class MapStyleBuilder {
    static func create() -> MapStyleVC {
        let controller = MapStyleVC()
        controller.hidesBottomBarWhenPushed = true
        let viewModel = MapStyleViewModel()
        controller.viewModel = viewModel
        return controller
    }
}
