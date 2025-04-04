//
//  SplitViewTrackingMapCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SplitViewTrackingMapCoordinator: Coordinator {
    weak var delegate: CoordinatorCompletionDelegate?
    weak var splitDelegate: SplitViewVisibilityProtocol?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = UINavigationController()
    var type: CoordinatorType { .tracking }
    
    private let splitViewController: UISplitViewController
    private var supplementaryNavigationController: UINavigationController? {
        return splitViewController.viewController(for: .supplementary)?.navigationController
    }
    
    private var floatingView: MapFloatingViewHandler?
    
    private var historyIsRootController: Bool = false
    private var supplementaryController: UIViewController {
        if historyIsRootController {
            return historyController
        } else {
            return dashboardController
        }
    }
    
    private lazy var dashboardController: TrackingDashboardController = {
        let controller = TrackingDashboardBuilder.create()
        controller.delegate = self
        controller.trackingSimulationHandler = { [weak self] in
            self?.showTrackingSimulationScene()
        }
        return controller
    }()
    
    private lazy var historyController: TrackingHistoryVC = {
        let controller = TrackingHistoryBuilder.create(isTrackingActive: false)
        return controller
    }()
    
    private lazy var secondaryController: TrackingVC = {
        let controller = TrackingVCBuilder.create()
        controller.delegate = self
        
        floatingView = MapFloatingViewHandler(viewController: controller)
        floatingView?.delegate = splitDelegate
        floatingView?.setupNavigationSearch(state: .primaryVisible, hideSearch: true)
        return controller
    }()
    
    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }
    
    func start() {
        showTrackingScene()
    }
    
    func setupNavigationSearch(state: MapSearchState) {
        floatingView?.setupNavigationSearch(state: .primaryVisible, hideSearch: true)
    }
}

extension SplitViewTrackingMapCoordinator: TrackingNavigationDelegate {
    func showDashboardFlow() {
        historyIsRootController = false
        guard splitViewController.viewController(for: .secondary) == secondaryController else { return }
        showNextTrackingScene()
    }
    
    func showNextTrackingScene() {
        setSupplementary()
        splitViewController.show(.supplementary)
    }
    
    func showTrackingSimulationScene() {
        let controller = TrackingSimulationIntroBuilder.create()
        controller.modalPresentationStyle = .automatic
        controller.isModalInPresentation = false
        
        controller.delegate = self
        controller.trackingSimulationHandler = { [weak self] in
            self?.showRouteTrackingScene()
        }
        controller.dismissHandler = { [weak self] in
            self?.splitViewController.dismiss(animated: true)
        }

        supplementaryNavigationController?.pushViewController(controller, animated: true)
        splitDelegate?.showSupplementary()
    }
    
    func showRouteTrackingScene() {
        let controller = TrackingSimulationBuilder.create()
        controller.modalPresentationStyle = .automatic
        controller.isModalInPresentation = false
        controller.trackingVC = secondaryController
        controller.viewModel = secondaryController.viewModel
        
        supplementaryNavigationController?.pushViewController(controller, animated: true)
        splitDelegate?.showSupplementary()
    }
    
    func showMapStyleScene() {
        let controller = ExploreMapStyleBuilder.create()
        
        controller.modalPresentationStyle = .formSheet
        controller.isModalInPresentation = true
        controller.dismissHandler = { [weak self] in
            self?.splitViewController.dismiss(animated: true)
        }
        if let sheet = controller.sheetPresentationController {
            sheet.preferredCornerRadius = NumberConstants.formSheetDefaultCornerRadius
        }
        
        splitViewController.present(controller, animated: true)
    }
    
    func showAttribution() {
        let controller = AttributionVCBuilder.create()
        controller.closeCallback = { [weak self] in
            self?.supplementaryNavigationController?.popViewController(animated: true)
        }
        supplementaryNavigationController?.pushViewController(controller, animated: true)
        splitDelegate?.showSupplementary()
    }
}

private extension SplitViewTrackingMapCoordinator {
    func showTrackingScene() {
        setSupplementary()
        setSecondary()
        secondaryController.navigationController?.navigationBar.isHidden = true
    }
    
    private func setSupplementary() {
        splitViewController.setViewController(supplementaryController, for: .supplementary)
    }
    
    private func setSecondary() {
        splitViewController.changeSecondaryViewController(to: secondaryController)
        splitViewController.show(.secondary)
    }
}
