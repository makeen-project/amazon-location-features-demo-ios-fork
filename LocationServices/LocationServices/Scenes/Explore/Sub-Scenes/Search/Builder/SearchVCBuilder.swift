//
//  SearchVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SearchVCBuilder {
    static func create() -> SearchVC {
        let controller = SearchVC()
        let locationService = LocationService()
        let viewModel = SearchViewModel(service: locationService)
        controller.viewModel = viewModel
        return controller
    }
}
