//
//  SplitViewCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

protocol SplitViewVisibilityProtocol {
    func showPrimary()
    func showOnlySecondary()
}

final class SplitViewCoordinator: Coordinator {

    weak var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = UINavigationController()
    var type: CoordinatorType { .main }
    var window: UIWindow?
    
    private let splitViewController: UISplitViewController
    private var showSearchOnMap: Bool = true
    
    private lazy var mapController: MapVC = {
        let vc = MapBuilder.create()
        vc.delegate = self
        return vc
    }()
    
    private lazy var sideBarController = SideBarBuilder.create()
    
    init(window: UIWindow?) {
        self.window = window
        
        splitViewController = UISplitViewController(style: .tripleColumn)
        splitViewController.preferredSplitBehavior = .tile
        setupSplitViewController()
    }
    
    func start() {
        window?.rootViewController = splitViewController
        showMapScene()
    }
    
    private func setupSplitViewController() {
        splitViewController.presentsWithGesture = false
        splitViewController.preferredDisplayMode = .secondaryOnly
        splitViewController.maximumPrimaryColumnWidth = 200
        splitViewController.delegate = self
    }
    
    private func showMapScene() {
        sideBarController.delegate = self
        
        splitViewController.setViewController(mapController, for: .secondary)
        splitViewController.setViewController(sideBarController, for: .primary)
        splitViewController.setViewController(UIViewController(), for: .supplementary)
    }
    
    private func createSelectedCoordinator(type: SideBarCellType) -> Coordinator {
        switch type {
        case .explore: fatalError(.errorToBeImplemented)
        case .tracking: fatalError(.errorToBeImplemented)
        case .geofence: fatalError(.errorToBeImplemented)
        case .settings: fatalError(.errorToBeImplemented)
        case .about: return SplitViewAboutCoordinator(splitViewController: splitViewController)
        }
    }
}

extension SplitViewCoordinator: SideBarDelegate {
    func showNextScene(type: SideBarCellType) {
        childCoordinators.removeAll()
        let coordinator = createSelectedCoordinator(type: type)
        childCoordinators.append(coordinator)
        coordinator.start()
        
    }
}

extension SplitViewCoordinator: SplitViewVisibilityProtocol {
    func showPrimary() {
        splitViewController.show(.primary)
    }
    
    func showOnlySecondary() {
        splitViewController.hide(.primary)
        splitViewController.hide(.supplementary)
    }
}

extension SplitViewCoordinator: MapNavigationDelegate { }


extension SplitViewCoordinator: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        guard showSearchOnMap else { return }
        
        switch displayMode {
        case .secondaryOnly, .primaryHidden:
            mapController.setupNavigationSearch(state: .onlySecondaryVisible)
        default:
            mapController.setupNavigationSearch(state: .primaryVisible)
        }
    }
}
