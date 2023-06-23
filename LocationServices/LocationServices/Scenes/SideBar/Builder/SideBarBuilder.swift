//
//  SideBarBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SideBarBuilder {
    static func create() -> SideBarVC {
        let viewModel = SideBarViewModel()
        let controller = SideBarVC()
        controller.viewModel = viewModel
        return controller
    }
}
