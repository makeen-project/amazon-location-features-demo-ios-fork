//
//  SettingsCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SettingsCoordinator: Coordinator {
    var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .explore }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showSettingsScene()
    }
}

private extension SettingsCoordinator {
    func showSettingsScene() {
        let controller = SettingsVCBuilder.create()
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }
}

extension SettingsCoordinator: SettingsNavigationDelegate {
    func showNextScene(type: SettingsCellType) {
        navigationController.navigationBar.isHidden = false
        switch type {
        case .units:
            showUnitScene()
        case .dataProvider:
            showDataProviderScene()
        case .mapStyle:
            showMapStyleScene()
        case .routeOption:
            showRouteOptionScene()
        }
    }
    
    private func showUnitScene() {
        let controller = UnitSceneBuilder.create()
        navigationController.pushViewController(controller, animated: true)
    }
    
    private func showDataProviderScene() {
        let controller = DataProviderBuilder.create()
        navigationController.pushViewController(controller, animated: true)
    }
    
    private func showMapStyleScene() {
        let controller = MapStyleBuilder.create()
        navigationController.pushViewController(controller, animated: true)
    }
    
    private func showRouteOptionScene() {
        let controller = RouteOptionBuilder.create()
        navigationController.pushViewController(controller, animated: true)
    }
    
    private func showResetPasswordScene() {
        let controller = ResetPasswordBuilder.create()
        navigationController.pushViewController(controller, animated: true)
    }
}
