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
        controller.delegate = self
        controller.trackingSimulationHandler = { [weak self] in
            self?.showTrackingSimulation()
        }
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: TabBarCoordinator.tabBarController!)
        controller.enableBottomSheetGrab(smallHeight: 0.48)
        currentBottomSheet = controller
    }
    
    func showTrackingSimulation() {
        let controller = TrackingSimulationBuilder.create()
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: TabBarCoordinator.tabBarController!)
        controller.setBottomSheetHeight(to: controller.getDetentHeight(heightFactor: 0.90))
        currentBottomSheet = controller
        
        controller.dismissHandler = { [weak self] in
            self?.currentBottomSheet?.dismissBottomSheet()
        }
    }
    
    
    func showTrackingHistory(isTrackingActive: Bool = false) {
        let controller = TrackingHistoryBuilder.create(isTrackingActive: isTrackingActive)
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: trackingController!)
        controller.enableBottomSheetGrab(smallHeight: 0.14)
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
            NotificationCenter.default.post(name: Notification.Name("updateMapViewButtons"), object: nil, userInfo: nil)
        }
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: trackingController!)
        controller.setBottomSheetHeight(to: controller.getLargeDetentHeight())
        currentBottomSheet = controller
    }
    
    func showLoginFlow() {
        (UIApplication.shared.delegate as? AppDelegate)?.navigationController = navigationController
        
        let controller = LoginVCBuilder.create()
        controller.dismissHandler = { [weak self] in
            self?.navigationController.dismiss(animated: true)
            let height:CGFloat = 8
            NotificationCenter.default.post(name: Notification.updateMapLayerItems, object: nil, userInfo: ["height": height])
        }
        
        controller.postLoginHandler = { [weak self] in
            self?.showLoginSuccess()
        }
        let height:CGFloat = 8
        NotificationCenter.default.post(name: Notification.updateMapLayerItems, object: nil, userInfo: ["height": height])
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
                let height:CGFloat = 8
                NotificationCenter.default.post(name: Notification.updateMapLayerItems, object: nil, userInfo: ["height": height])
            }
            let height:CGFloat = 8
            NotificationCenter.default.post(name: Notification.updateMapLayerItems, object: nil, userInfo: ["height": height])
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
        controller.closeCallback = { [weak self] in
            self?.navigationController.popViewController(animated: true)
            self?.navigationController.navigationBar.isHidden = true
        }
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
