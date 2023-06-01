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
    var geofenceController: GeofenceVC?
    weak var currentBottomSheet:UIViewController?
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
        geofenceController = controller
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
    
    func dismissCurrentBottomSheet(geofences: [GeofenceDataModel], shouldDashboardShow: Bool) {
        currentBottomSheet?.view.removeFromSuperview()
            if shouldDashboardShow {
                self.showDashboardFlow(geofences: geofences, lat: nil, long: nil)
            }
    }

    func showSearchSceneWith(lat: Double?, long: Double?) {
      
        let controller = SearchVCBuilder.create()
        controller.userLocation = (lat, long)

        currentBottomSheet?.view.removeFromSuperview()
        controller.presentBottomSheet(parentController: geofenceController!)
        controller.enableBottomSheetGrab()
        currentBottomSheet = controller
    }
    
    func showDashboardFlow(geofences: [GeofenceDataModel], lat: Double?, long: Double?) {
        let controller = GeofenceDashboardBuilder.create(lat: lat, long: long, geofences: geofences)
        
        controller.addGeofence = { [weak self] parameters in
            self?.showAddGeofenceFlow(activeGeofencesLists: parameters.activeGeofences,
                                      isEditingSceneEnabled: parameters.isEditingSceneEnabled,
                                      model: parameters.geofenceData,
                                      lat: parameters.userlocation?.lat,
                                      long: parameters.userlocation?.long)
            
        }

        currentBottomSheet?.view.removeFromSuperview()
        controller.presentBottomSheet(parentController: geofenceController!)
        controller.enableBottomSheetGrab()
        currentBottomSheet = controller
    }
    
    func showAddGeofenceFlow(activeGeofencesLists: [GeofenceDataModel],
                             isEditingSceneEnabled: Bool = false,
                             model: GeofenceDataModel?,
                             lat: Double?,
                             long: Double?) {
        let controller = AddGeofenceBuilder.create(activeGeofencesLists: activeGeofencesLists,
                                                   isEditingSceneEnabled: isEditingSceneEnabled,
                                                   model: model,
                                                   lat: lat,
                                                   long: long)
        controller.delegate = self
        
        currentBottomSheet?.view.removeFromSuperview()
        controller.presentBottomSheet(parentController: geofenceController!)
        controller.enableBottomSheetGrab()
        currentBottomSheet = controller
    }
    
    func showMapStyleScene() {
        dismissCurrentScene(geofences: [], shouldDashboardShow: false)
        let controller = ExploreMapStyleBuilder.create()
        controller.dismissHandler = { [weak self] in
            self?.currentBottomSheet?.view.removeFromSuperview()
        }
        
        currentBottomSheet?.view.removeFromSuperview()
        controller.presentBottomSheet(parentController: geofenceController!)
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
