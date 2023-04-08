//
//  PostLoginBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class PostLoginBuilder {
    static func create() -> PostLoginVC {
        let vc = PostLoginVC()
        let service = AWSLoginService()
        service.viewController = vc
        let vm = PostLoginViewModel(awsLoginService: service)
        vc.viewModel = vm
        return vc
    }
}
