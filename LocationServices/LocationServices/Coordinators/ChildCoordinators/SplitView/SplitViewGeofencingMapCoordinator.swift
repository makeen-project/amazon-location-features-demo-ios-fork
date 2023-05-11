//
//  SplitViewGeofencingMapCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SplitViewGeofencingMapCoordinator: Coordinator {
    weak var delegate: CoordinatorCompletionDelegate?
    weak var splitDelegate: SplitViewVisibilityProtocol?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = UINavigationController()
    var type: CoordinatorType { .geofence }
    var directionHandler: VoidHandler?
    
    private let splitViewController: UISplitViewController
    private var supplementaryNavigationController: UINavigationController? {
        return splitViewController.viewController(for: .supplementary)?.navigationController
    }
    
    private var floatingView: MapFloatingViewHandler?
    
    private lazy var supplementaryController: GeofenceDashboardVC = {
        let controller = GeofenceDashboardBuilder.create(lat: nil, long: nil, geofences: [])
        controller.addGeofence = { [weak self] parameters in
            self?.showAddGeofenceFlow(activeGeofencesLists: parameters.activeGeofences,
                                      isEditingSceneEnabled: parameters.isEditingSceneEnabled,
                                      model: parameters.geofenceData,
                                      lat: parameters.userlocation?.lat,
                                      long: parameters.userlocation?.long)
            
        }
        return controller
    }()
    
    private lazy var secondaryController: GeofenceVC = {
        let controller = GeofenceBuilder.create()
        controller.delegate = self
        controller.directioButtonHandler = {
            self.directionHandler?()
        }
        
        floatingView = MapFloatingViewHandler(viewController: controller)
        floatingView?.delegate = splitDelegate
        floatingView?.setupNavigationSearch(state: .onlySecondaryVisible)
        return controller
    }()
    
    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }

    func start() {
        showGeofenceScene()
    }
    
    func setupNavigationSearch(state: MapSearchState) {
        floatingView?.setupNavigationSearch(state: state)
    }
}

extension SplitViewGeofencingMapCoordinator: GeofenceNavigationDelegate {
    func dismissCurrentScene(geofences: [GeofenceDataModel], shouldDashboardShow: Bool) {
        if shouldDashboardShow {
            showDashboardFlow(geofences: geofences, lat: nil, long: nil)
        } else {
            splitDelegate?.showOnlySecondary()
            supplementaryNavigationController?.popToRootViewController(animated: false)
        }
    }
    
    func showDashboardFlow(geofences: [GeofenceDataModel], lat: Double?, long: Double?) {
        supplementaryController.userlocation = (lat, long)
        supplementaryController.datas = geofences
        supplementaryController.viewModel.geofences = geofences
        
        supplementaryNavigationController?.popToRootViewController(animated: false)
        splitDelegate?.showSupplementary()
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

private extension SplitViewGeofencingMapCoordinator {
    func showGeofenceScene() {
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
