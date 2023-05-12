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
    
    private lazy var supplementaryController: TrackingDashboardController = {
        let controller = TrackingDashboardBuilder.create()
        controller.trackingHistoryHandler = { [weak self] in
            self?.showTrackingHistory()
        }
        controller.closeHandler = { [weak self] in
            self?.navigationController.dismiss(animated: true, completion: nil)
        }
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
        
    }
    
    func showTrackingHistory(isTrackingActive: Bool = false) {
        let controller = TrackingHistoryBuilder.create(isTrackingActive: isTrackingActive)
        supplementaryNavigationController?.pushViewController(controller, animated: true)
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
        let controller = AttributionVCBuilder.create(withNavBar: true)
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