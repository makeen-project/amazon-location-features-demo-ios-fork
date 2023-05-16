//
//  TrackingCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class TrackingCoordinator: Coordinator {
    var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .explore }

    var didSendEventClosure: VoidHandler?
    var didSendDirectionEvent: VoidHandler?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showTrackingScene()
    }
}

extension TrackingCoordinator: TrackingNavigationDelegate {
 
    func dismissCurrentScene() {
        self.navigationController.dismiss(animated: true)
    }
    
    func showNextTrackingScene() {
        showDashboardFlow()
    }
    
    func showDashboardFlow() {
        let controller = TrackingDashboardBuilder.create()
        controller.modalPresentationStyle = .pageSheet
        
        controller.trackingHistoryHandler = { [weak self] in
            self?.showTrackingHistory()
        }
        
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = NumberConstants.formSheetDefaultCornerRadius
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        
        navigationController.present(controller, animated: true)
    }
    
    func showTrackingHistory(isTrackingActive: Bool = false) {
        navigationController.dismiss(animated: false, completion: { [weak self] in
            let controller = TrackingHistoryBuilder.create(isTrackingActive: isTrackingActive)
            controller.modalPresentationStyle = .pageSheet
            
            if let sheet = controller.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.preferredCornerRadius = NumberConstants.formSheetDefaultCornerRadius
                sheet.prefersGrabberVisible = true
                sheet.largestUndimmedDetentIdentifier = .medium
            }
            
            self?.navigationController.present(controller, animated: true)
        })
    }
    
    func showMapStyleScene() {
        dismissCurrentScene()
        let controller = ExploreMapStyleBuilder.create()
        controller.dismissHandler = { [weak self] in
            self?.navigationController.dismiss(animated: true)
        }
        controller.modalPresentationStyle = .pageSheet
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = NumberConstants.formSheetDefaultCornerRadius
        }
        navigationController.present(controller, animated: true)
    }
    
    func showLoginFlow() {
        (UIApplication.shared.delegate as? AppDelegate)?.navigationController = navigationController
        
        let controller = LoginVCBuilder.create()
        controller.dismissHandler = { [weak self] in
            self?.navigationController.dismiss(animated: true)
        }
        
        controller.postLoginHandler = { [weak self] in
            self?.showLoginSuccess()
        }
        
        controller.modalPresentationStyle = .pageSheet

        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.selectedDetentIdentifier = .large
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = NumberConstants.formSheetDefaultCornerRadius
        }
        navigationController.present(controller, animated: true)
    }
    
    func showLoginSuccess() {
        (UIApplication.shared.delegate as? AppDelegate)?.navigationController = navigationController
        
        navigationController.dismiss(animated: true) { [weak self] in
            let controller = PostLoginBuilder.create()
            controller.dismissHandler = { [weak self] in
                self?.navigationController.dismiss(animated: true)
            }
            controller.modalPresentationStyle = .pageSheet

            if let sheet = controller.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.selectedDetentIdentifier = .large
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.preferredCornerRadius = NumberConstants.formSheetDefaultCornerRadius
            }
            self?.navigationController.present(controller, animated: true)
        }
    }
    
    func showAttribution() {
        let controller = AttributionVCBuilder.create()
        navigationController.pushViewController(controller, animated: true)
    }
}

private extension TrackingCoordinator {
    func showTrackingScene() {
        let controller = TrackingVCBuilder.create()
        controller.geofenceHandler = {
            self.didSendEventClosure?()
        }
        
        controller.directionHandler = {
            self.didSendDirectionEvent?()
        }
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }
}
