//
//  AppCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

protocol AppCoordinatorProtocol: Coordinator {
    func startLoginFlow()
    func startMainFlow()
}

final class AppCoordinator: AppCoordinatorProtocol {
    weak var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .main }

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        startMainFlow()
    }

    func startLoginFlow() {

    }

    func startMainFlow() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        tabBarCoordinator.delegate = self
        tabBarCoordinator.start()
        childCoordinators.append(tabBarCoordinator)
    }
}

extension AppCoordinator: CoordinatorCompletionDelegate {
    func didComplete(completedCoordinator: Coordinator) {
        switch completedCoordinator.type {
        case .main:
            startMainFlow()
        case .login:
            startLoginFlow()
        default: break
        }
    }
}
