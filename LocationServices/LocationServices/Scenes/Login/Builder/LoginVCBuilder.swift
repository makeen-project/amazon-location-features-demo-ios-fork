//
//  LoginVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class LoginVCBuilder {
    static func create() -> LoginVC {
        var controller = LoginVC()
        let vm = LoginViewModel()
        vm.awsLoginService = AWSLoginService()
        controller.viewModel = vm
        return controller
    }
    
    static func create(from settingScene: Bool) -> LoginVC {
        var controller = LoginVC()
        let vm = LoginViewModel()
        vm.awsLoginService = AWSLoginService()
        controller.isFromSettingScene = settingScene
        controller.viewModel = vm
        return controller
    }
    
}
