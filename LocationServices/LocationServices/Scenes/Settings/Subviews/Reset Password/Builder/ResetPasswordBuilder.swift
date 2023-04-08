//
//  ResetPasswordBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class ResetPasswordBuilder {
    static func create() -> ResetPasswordVC {
        let controller = ResetPasswordVC()
        let vm = ResetPasswordViewModel()
        controller.viewModel = vm
        return controller
    }
}
