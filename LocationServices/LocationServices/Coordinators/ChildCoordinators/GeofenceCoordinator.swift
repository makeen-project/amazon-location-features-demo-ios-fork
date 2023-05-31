//
//  GeofenceCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class GeofenceCoordinator: Coordinator {
    var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .explore }
    
    var directionHandler: VoidHandler?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showGeofenceScene()
    }
}

private extension GeofenceCoordinator {
    func showGeofenceScene() {
        let controller = GeofenceBuilder.create()
        controller.delegate = self
        controller.directioButtonHandler = {
            self.directionHandler?()
        }
        navigationController.pushViewController(controller, animated: true)
    }
}

extension GeofenceCoordinator: GeofenceNavigationDelegate {
    func dismissCurrentScene(geofences: [GeofenceDataModel], shouldDashboardShow: Bool) {
        self.navigationController.dismiss(animated: true) {
            if shouldDashboardShow {
                self.showDashboardFlow(geofences: geofences, lat: nil, long: nil)
            }
        }
    }
    
    func showDashboardFlow(geofences: [GeofenceDataModel], lat: Double?, long: Double?) {
        let controller = GeofenceDashboardBuilder.create(lat: lat, long: long, geofences: geofences)
        controller.modalPresentationStyle = .pageSheet
        
        controller.addGeofence = { [weak self] parameters in
            self?.showAddGeofenceFlow(activeGeofencesLists: parameters.activeGeofences,
                                      isEditingSceneEnabled: parameters.isEditingSceneEnabled,
                                      model: parameters.geofenceData,
                                      lat: parameters.userlocation?.lat,
                                      long: parameters.userlocation?.long)
            
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
    
    func showAddGeofenceFlow(activeGeofencesLists: [GeofenceDataModel],
                             isEditingSceneEnabled: Bool = false,
                             model: GeofenceDataModel?,
                             lat: Double?,
                             long: Double?) {
        
        if let controller = navigationController.presentedViewController as? AddGeofenceVC {
            controller.update(lat: lat, long: long)
            return
        }
        
        dismissCurrentScene(geofences: [], shouldDashboardShow: false)
        let controller = AddGeofenceBuilder.create(activeGeofencesLists: activeGeofencesLists,
                                                   isEditingSceneEnabled: isEditingSceneEnabled,
                                                   model: model,
                                                   lat: lat,
                                                   long: long)
        controller.delegate = self
        controller.modalPresentationStyle = .pageSheet

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
    
    func showMapStyleScene() {
        dismissCurrentScene(geofences: [], shouldDashboardShow: false)
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
        controller.closeCallback = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(controller, animated: true)
    }
}
