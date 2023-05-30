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
    var window: UIWindow?

    init(navigationController: UINavigationController, window: UIWindow?) {
        self.navigationController = navigationController
        self.window = window
    }

    func start() {
        showSplash()
    }

    func startLoginFlow() {

    }
    
    private func showSplash() {
        let splashVC = SplashBuilder.create()
        splashVC.setupCompleteHandler = { [weak self] in
            self?.startMainFlow()
        }
        
        navigationController.navigationBar.isHidden = true
        navigationController.setViewControllers([splashVC], animated: false)
    }

    func startMainFlow() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            startIPhoneFlow()
        } else {
            startIPadFlow()
        }
    }
    
    private func startIPhoneFlow() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        tabBarCoordinator.delegate = self
        tabBarCoordinator.start()
        childCoordinators.append(tabBarCoordinator)
    }
    
    private func startIPadFlow() {
        let coordinator = SplitViewCoordinator(window: window)
        coordinator.delegate = self
        coordinator.start()
        childCoordinators.append(coordinator)
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
