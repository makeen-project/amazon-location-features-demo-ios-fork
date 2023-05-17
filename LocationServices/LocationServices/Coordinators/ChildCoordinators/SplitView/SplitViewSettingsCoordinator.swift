//
//  SplitViewSettingsCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SplitViewSettingsCoordinator: Coordinator {
    var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = UINavigationController()
    var type: CoordinatorType { .explore }
    
    private let splitViewController: UISplitViewController

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }
    
    func start() {
        showSettingsScene()
    }
}

private extension SplitViewSettingsCoordinator {
    func showSettingsScene() {
        let controller = SettingsVCBuilder.create()
        controller.delegate = self
        splitViewController.setViewController(controller, for: .supplementary)
        splitViewController.show(.supplementary)
        showNextScene(type: .dataProvider)
    }
}

extension SplitViewSettingsCoordinator: SettingsNavigationDelegate {
    func showNextScene(type: SettingsCellType) {
        switch type {
        case .units:
            showUnitScene()
        case .dataProvider:
            showDataProviderScene()
        case .mapStyle:
            showMapStyleScene()
        case .routeOption:
            showRouteOptionScene()
        case .resetPassword:
            showResetPasswordScene()
        case .awsCloud:
            showAwsCloudFormationscene()
        }
    }
    
    private func showUnitScene() {
        let controller = UnitSceneBuilder.create()
        changeSecondaryVC(to: controller)
    }
    
    private func showDataProviderScene() {
        let controller = DataProviderBuilder.create()
        changeSecondaryVC(to: controller)
    }
    
    private func showMapStyleScene() {
        let controller = MapStyleBuilder.create()
        changeSecondaryVC(to: controller)
    }
    
    private func showRouteOptionScene() {
        let controller = RouteOptionBuilder.create()
        changeSecondaryVC(to: controller)
    }
    
    private func showResetPasswordScene() {
        let controller = ResetPasswordBuilder.create()
        changeSecondaryVC(to: controller)
    }
    
    private func showAwsCloudFormationscene() {
        let controller = LoginVCBuilder.create(from: true)
        controller.isFromSettingScene = true
        changeSecondaryVC(to: controller)
    }
    
    private func changeSecondaryVC(to viewController: UIViewController) {
        splitViewController.changeSecondaryViewController(to: viewController)
        splitViewController.show(.secondary)
    }
}

