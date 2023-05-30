//
//  DataProviderBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class DataProviderBuilder {
    static func create() -> DataProviderVC {
        let controller = DataProviderVC()
        controller.hidesBottomBarWhenPushed = true
        let viewModel = DataProviderViewModel()
        controller.viewModel = viewModel
        return controller
    }
}
