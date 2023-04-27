//
//  SplitViewCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SplitViewCoordinator: Coordinator {

    var splitViewController: UISplitViewController
    weak var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = UINavigationController()
    var type: CoordinatorType { .main }
    var window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
        self.splitViewController = UISplitViewController(style: .tripleColumn)
        splitViewController.presentsWithGesture = false
    }
    
    func start() {
        window?.rootViewController = splitViewController
        splitViewController.preferredDisplayMode = .secondaryOnly
        showMapScene()
    }
}

extension SplitViewCoordinator {
    func showMapScene() {
        let controller = MapBuilder.create()
        splitViewController.setViewController(controller, for: .secondary)
    }
}
