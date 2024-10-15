//
//  SplashBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SplashBuilder {
    static func create() -> SplashVC {
        let vc = SplashVC()
        let service = AWSLoginService.default()
        service.viewController = vc
        let vm = SplashViewModel(loginService: service)
        vc.viewModel = vm
        return vc
    }
}
