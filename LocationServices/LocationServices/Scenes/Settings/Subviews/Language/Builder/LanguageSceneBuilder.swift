//
//  LanguageSceneBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class LanguageSceneBuilder {
    static func create() -> LanguageVC {
        let controller = LanguageVC()
        let vm = LanguageSceneViewModel()
        controller.viewModel = vm
        return controller
    }
}
