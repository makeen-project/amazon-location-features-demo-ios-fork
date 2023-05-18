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
        controller.trackingHistoryHandler = { [weak self] in
            self?.showTrackingHistory()
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
        floatingView?.setupNavigationSearch(state: .onlySecondaryVisible)
        return controller
    }()
    
    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }
    
    func start() {
        showTrackingScene()
    }
    
    func setupNavigationSearch(state: MapSearchState) {
        floatingView?.setupNavigationSearch(state: state)
    }
}

extension SplitViewTrackingMapCoordinator: TrackingNavigationDelegate {
    func showNextTrackingScene() {
        setSupplementary()
        splitViewController.show(.supplementary)
    }
    
    func showDashboardFlow() {
        historyIsRootController = false
        guard splitViewController.viewController(for: .secondary) == secondaryController else { return }
        showNextTrackingScene()
    }
    
    func showTrackingHistory(isTrackingActive: Bool = false) {
        historyIsRootController = true
        let controller = historyController
        controller.viewModel.changeTrackingStatus(isTrackingActive)
        guard splitViewController.viewController(for: .secondary) == secondaryController else { return }
        supplementaryNavigationController?.setViewControllers([controller],
                                                              animated: true)
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
    
    func showLoginFlow() {
        (UIApplication.shared.delegate as? AppDelegate)?.navigationController = supplementaryNavigationController
        
        let controller = LoginVCBuilder.create()
        controller.dismissHandler = { [weak self] in
            self?.splitViewController.dismiss(animated: true)
        }
        
        controller.postLoginHandler = { [weak self] in
            self?.showLoginSuccess()
        }
        
        controller.modalPresentationStyle = .formSheet

        if let sheet = controller.sheetPresentationController {
            sheet.preferredCornerRadius = NumberConstants.formSheetDefaultCornerRadius
        }
        splitViewController.present(controller, animated: true)
    }
    
    func showLoginSuccess() {
        (UIApplication.shared.delegate as? AppDelegate)?.navigationController = supplementaryNavigationController
        
        splitViewController.dismiss(animated: true) { [weak self] in
            let controller = PostLoginBuilder.create()
            controller.dismissHandler = { [weak self] in
                self?.splitViewController.dismiss(animated: true)
            }
            controller.modalPresentationStyle = .formSheet

            if let sheet = controller.sheetPresentationController {
                sheet.preferredCornerRadius = NumberConstants.formSheetDefaultCornerRadius
            }
            self?.splitViewController.present(controller, animated: true)
        }
    }
    
    func showAttribution() {
        let controller = AttributionVCBuilder.create()
        supplementaryNavigationController?.pushViewController(controller, animated: true)
    }
}

private extension SplitViewTrackingMapCoordinator {
    func showTrackingScene() {
        setSupplementary()
        setSecondary()
    }
    
    private func setSupplementary() {
        splitViewController.setViewController(supplementaryController, for: .supplementary)
    }
    
    private func setSecondary() {
        splitViewController.changeSecondaryViewController(to: secondaryController)
        splitViewController.show(.secondary)
    }
}
