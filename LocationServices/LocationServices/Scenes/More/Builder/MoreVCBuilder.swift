//
//  MoreVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class MoreVCBuilder {
    static func create() -> MoreVC {
        let viewModel = MoreViewModel()
        let controller = MoreVC()
        controller.viewModel = viewModel
        return controller
    }
}
