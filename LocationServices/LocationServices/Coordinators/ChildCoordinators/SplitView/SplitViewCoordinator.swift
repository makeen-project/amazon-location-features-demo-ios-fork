//
//  SplitViewCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

protocol SplitViewVisibilityProtocol: AnyObject {
    func showPrimary()
    func showSupplementary()
    func showOnlySecondary()
    func showSearchScene()
}

final class SplitViewCoordinator: Coordinator {

    weak var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = UINavigationController()
    var type: CoordinatorType { .main }
    var window: UIWindow?
    
    private let splitViewController: UISplitViewController
    private var showSearchOnMap: Bool = true
    
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
        
        splitViewController.setViewController(sideBarController, for: .primary)
        showNextScene(type: .explore)
    }
    
    private func getSelectedCoordinator(type: SideBarCellType) -> Coordinator {
        switch type {
        case .explore: return getExploreCoordinator()
        case .tracking: return getTrackingCoordinator()
        case .geofence: return getGeofenceCoordinator()
        case .settings: return getSettingsCoordinator()
        case .about: return getAboutCoordinator()
        }
    }
    
    private func getExploreCoordinator() -> Coordinator {
        if let coordinator = childCoordinators.first(where: { $0 is SplitViewExploreMapCoordinator }) {
            return coordinator
        }
        
        let coordinator = SplitViewExploreMapCoordinator(splitViewController: splitViewController)
        coordinator.geofenceHandler = { [weak self] in
            self?.showNextScene(type: .geofence)
        }
        coordinator.splitDelegate = self
        return coordinator
    }
    
    private func getTrackingCoordinator() -> Coordinator {
        if let coordinator = childCoordinators.first(where: { $0 is SplitViewTrackingMapCoordinator }) {
            return coordinator
        }
        let coordinator = SplitViewTrackingMapCoordinator(splitViewController: splitViewController)
        coordinator.splitDelegate = self
        return coordinator
    }
    
    private func getGeofenceCoordinator() -> Coordinator {
        if let coordinator = childCoordinators.first(where: { $0 is SplitViewGeofencingMapCoordinator }) {
            return coordinator
        }
        let coordinator = SplitViewGeofencingMapCoordinator(splitViewController: splitViewController)
        coordinator.splitDelegate = self
        return coordinator
    }
    
    private func getSettingsCoordinator() -> Coordinator {
        if let coordinator = childCoordinators.first(where: { $0 is SplitViewSettingsCoordinator }) {
            return coordinator
        } else {
            return SplitViewSettingsCoordinator(splitViewController: splitViewController)
        }
    }
    
    private func getAboutCoordinator() -> Coordinator {
        if let coordinator = childCoordinators.first(where: { $0 is SplitViewAboutCoordinator }) {
            return coordinator
        } else {
            return SplitViewAboutCoordinator(splitViewController: splitViewController)
        }
    }
    
    // MARK: - Utility
    private func updateChildCoordinatorsNavState() {
        let mapState: MapSearchState
        switch splitViewController.displayMode {
        case .secondaryOnly:
            mapState = .onlySecondaryVisible
        case .twoBesideSecondary,
                .twoOverSecondary,
                .twoDisplaceSecondary:
            mapState = .primaryVisible
        default:
            mapState = .primaryVisible
            break
        }
        (getExploreCoordinator() as? SplitViewExploreMapCoordinator)?.displayModeChanged(displayMode: splitViewController.displayMode)
        (getTrackingCoordinator() as? SplitViewTrackingMapCoordinator)?.setupNavigationSearch(state: mapState)
        (getGeofenceCoordinator() as? SplitViewGeofencingMapCoordinator)?.setupNavigationSearch(state: mapState)
    }
}

extension SplitViewCoordinator: SideBarDelegate {
    func showNextScene(type: SideBarCellType) {
        let coordinator = getSelectedCoordinator(type: type)
        coordinator.delegate = delegate
        childCoordinators.append(coordinator)
        coordinator.start()
        // TODO: Consider updating state more grecefully
        updateChildCoordinatorsNavState()
    }
}

extension SplitViewCoordinator: SplitViewVisibilityProtocol {
    
    @objc func showPrimary() {
        splitViewController.show(.primary)
    }
    
    @objc func hidePrimary() {
        splitViewController.hide(.primary)
    }
    
    func showSupplementary() {
        splitViewController.show(.supplementary)
    }
    
    func showSearchScene() {
        showNextScene(type: .explore)
        showSupplementary()
    }
    
    func showOnlySecondary() {
        splitViewController.hide(.primary)
        splitViewController.hide(.supplementary)
    }
    
    @objc func popSupplementary() {
        splitViewController.navigationController?.popViewController(animated: true)
    }
}

extension SplitViewCoordinator: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        guard showSearchOnMap else { return }
        
        let mapState: MapSearchState
        let sideBarButtonItem: UIBarButtonItem?
        let viewControllerForShowSecondaryButton: UIViewController?
        let viewControllerWithoutShowSecondaryButton: UIViewController?
        
        switch displayMode {
        case .secondaryOnly:
            mapState = .onlySecondaryVisible
            sideBarButtonItem = nil
            viewControllerForShowSecondaryButton = nil
            viewControllerWithoutShowSecondaryButton = nil
        case .twoBesideSecondary, .twoOverSecondary, .twoDisplaceSecondary:
            mapState = .primaryVisible
            sideBarButtonItem = UIBarButtonItem(image: .sidebarLeft, style: .done, target: self, action: #selector(hidePrimary))
            viewControllerForShowSecondaryButton = splitViewController.viewController(for: .primary)
            viewControllerWithoutShowSecondaryButton = splitViewController.viewController(for: .supplementary)
        default:
            mapState = .primaryVisible
            sideBarButtonItem = UIBarButtonItem(image: .sidebarLeft, style: .done, target: self, action: #selector(showPrimary))
            
            viewControllerForShowSecondaryButton = splitViewController.viewController(for: .supplementary)?.navigationController?.viewControllers.first
            
            viewControllerWithoutShowSecondaryButton = splitViewController.viewController(for: .primary)
        }
        
        (getExploreCoordinator() as? SplitViewExploreMapCoordinator)?.displayModeChanged(displayMode: displayMode)
        (getTrackingCoordinator() as? SplitViewTrackingMapCoordinator)?.setupNavigationSearch(state: mapState)
        (getGeofenceCoordinator() as? SplitViewGeofencingMapCoordinator)?.setupNavigationSearch(state: mapState)
        
        sideBarButtonItem?.tintColor = .lsPrimary
        viewControllerForShowSecondaryButton?.navigationItem.leftBarButtonItem = sideBarButtonItem
        viewControllerWithoutShowSecondaryButton?.navigationItem.leftBarButtonItem = nil
    }
}
