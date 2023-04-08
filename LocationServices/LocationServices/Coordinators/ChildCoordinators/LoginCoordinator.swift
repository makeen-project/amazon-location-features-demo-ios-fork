//
//  LoginCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class LoginCoordinator: Coordinator {
    weak var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .login }

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showLoginScene()
    }
}

private extension LoginCoordinator {
    func showLoginScene() {

    }
}
