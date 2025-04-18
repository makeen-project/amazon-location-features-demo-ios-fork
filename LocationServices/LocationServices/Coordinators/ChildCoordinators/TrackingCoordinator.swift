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
        currentBottomSheet?.dismissBottomSheet()
        let controller = TrackingSimulationIntroBuilder.create()
        controller.delegate = self
        controller.trackingSimulationHandler = { [weak self] in
            self?.showRouteTrackingScene()
        }
        controller.presentBottomSheet(parentController: TabBarCoordinator.tabBarController!)
        controller.setBottomSheetHeight(to: controller.getDetentHeight(heightFactor: 0.90))
        currentBottomSheet = controller
        
        controller.dismissHandler = { [weak self] in
            self?.currentBottomSheet?.dismissBottomSheet()
        }
    }
    
    func showRouteTrackingScene() {
        let controller = TrackingSimulationBuilder.create()
        controller.trackingVC = trackingController
        controller.viewModel = trackingController?.viewModel
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: TabBarCoordinator.tabBarController!)
        controller.enableBottomSheetGrab(smallHeight: 0.27, mediumHeight: 0.50, largeHeight: 0.90)
        controller.updateBottomSheetHeight(to: controller.getSmallDetentHeight())
        currentBottomSheet = controller
    }
    
    func showMapStyleScene() {
        dismissCurrentScene()
        let controller = ExploreMapStyleBuilder.create()
        controller.dismissHandler = { [weak self] in
            self?.currentBottomSheet?.dismissBottomSheet()
            self?.showDashboardFlow()
            NotificationCenter.default.post(name: Notification.Name("updateMapViewButtons"), object: nil, userInfo: nil)
        }
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: trackingController!)
        controller.setBottomSheetHeight(to: controller.getLargeDetentHeight())
        currentBottomSheet = controller
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
