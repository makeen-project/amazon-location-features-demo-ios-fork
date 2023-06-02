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
    
    weak var currentBottomSheet:UIViewController?
    
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

        controller.trackingHistoryHandler = { [weak self] in
            self?.showTrackingHistory(isTrackingActive: true)
        }
        
        controller.closeHandler = { [weak self] in
            self?.navigationController.dismiss(animated: true, completion: nil)
        }
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: trackingController!)
        currentBottomSheet = controller
    }
    
    func showTrackingHistory(isTrackingActive: Bool = false) {
        let controller = TrackingHistoryBuilder.create(isTrackingActive: isTrackingActive)
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: trackingController!)
        controller.enableBottomSheetGrab()
        currentBottomSheet = controller
        
        // Starting tracking by default when tapping on Enable tracking button
        NotificationCenter.default.post(name: Notification.updateStartTrackingButton, object: nil, userInfo: ["state": isTrackingActive])
    }
    
    func showMapStyleScene() {
        dismissCurrentScene()
        let controller = ExploreMapStyleBuilder.create()
        controller.dismissHandler = { [weak self] in
            self?.currentBottomSheet?.dismissBottomSheet()
            if(self?.trackingController?.viewModel.isTrackingActive == true){
                self?.showTrackingHistory(isTrackingActive: true)
            }
            else { self?.showDashboardFlow() }
        }
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: trackingController!)
        controller.enableBottomSheetGrab()
        currentBottomSheet = controller
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
        trackingController?.geofenceHandler = {
            self.didSendEventClosure?()
        }
        
        trackingController?.directionHandler = {
            self.didSendDirectionEvent?()
        }
        trackingController?.delegate = self
        navigationController.pushViewController(trackingController!, animated: true)
    }
}
