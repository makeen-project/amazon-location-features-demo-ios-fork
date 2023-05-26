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
    
    var trackingController:TrackingVC?
    
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
            self?.navigationController.dismiss(animated: false, completion: {
                self?.showTrackingHistory(isTrackingActive: true)
            })
        }
        
        controller.closeHandler = { [weak self] in
            self?.navigationController.dismiss(animated: true, completion: nil)
        }

        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 10
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        trackingController!.present(controller, animated: true)
    }
    
    func showTrackingHistory(isTrackingActive: Bool = false) {
        let controller = TrackingHistoryBuilder.create(isTrackingActive: isTrackingActive)
        controller.modalPresentationStyle = .pageSheet
        
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.preferredCornerRadius = 10
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        trackingController!.present(controller, animated: true)
        
        // Starting tracking by default when tapping on Enable tracking button
        NotificationCenter.default.post(name: Notification.updateStartTrackingButton, object: nil, userInfo: ["state": isTrackingActive])
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
            sheet.preferredCornerRadius = 10
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
            sheet.preferredCornerRadius = 10
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
                sheet.preferredCornerRadius = 10
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
        trackingController = TrackingVCBuilder.create()
        trackingController!.geofenceHandler = {
            self.didSendEventClosure?()
        }
        
        trackingController!.directionHandler = {
            self.didSendDirectionEvent?()
        }
        trackingController!.delegate = self
        navigationController.pushViewController(trackingController!, animated: true)
    }
}
