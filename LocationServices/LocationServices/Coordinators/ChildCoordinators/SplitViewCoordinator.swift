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
        self.splitViewController.presentsWithGesture = false
    }
    
    func start() {
        window?.rootViewController = splitViewController
        splitViewController.preferredDisplayMode = .secondaryOnly
        splitViewController.maximumPrimaryColumnWidth = 200
        showMapScene()
    }
}

extension SplitViewCoordinator {
    func showMapScene() {
        let controller = MapBuilder.create()
        splitViewController.setViewController(controller, for: .secondary)
        
        let sideBarController = SideBarBuilder.create()
        splitViewController.setViewController(sideBarController, for: .primary)
        splitViewController.show(.primary)
    }
}
