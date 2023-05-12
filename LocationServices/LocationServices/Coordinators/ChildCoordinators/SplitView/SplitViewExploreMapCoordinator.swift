//
//  SplitViewExploreMapCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SplitViewExploreMapCoordinator: Coordinator {
    weak var delegate: CoordinatorCompletionDelegate?
    weak var splitDelegate: SplitViewVisibilityProtocol?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = UINavigationController()
    var type: CoordinatorType { .explore }
    var geofenceHandler: VoidHandler?
    
    private let splitViewController: UISplitViewController
    private var supplementaryNavigationController: UINavigationController? {
        return splitViewController.viewController(for: .supplementary)?.navigationController
    }
    
    private var floatingView: MapFloatingViewHandler?
    
    private lazy var supplementaryController: SearchVC = {
        let controller = SearchVCBuilder.create()
        controller.delegate = self
        return controller
    }()
    
    private lazy var secondaryController: ExploreVC = {
        let controller = ExploreVCBuilder.create()
        controller.delegate = self
        controller.geofenceHandler = {
            self.geofenceHandler?()
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
        showExploreScene()
    }
    
    func setupNavigationSearch(state: MapSearchState) {
        floatingView?.setupNavigationSearch(state: state, hideSearch: true)
    }
}

extension SplitViewExploreMapCoordinator: ExploreNavigationDelegate {
    func showMapStyles() {
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
    
    func showDirections(isRouteOptionEnabled: Bool?,
                        firstDestionation: MapModel?,
                        secondDestionation: MapModel?,
                        lat: Double?,
                        long: Double?
    ) {
        let controller = DirectionVCBuilder.create()
        controller.isInSplitViewController = true
        controller.dismissHandler = { [weak self] in
            self?.supplementaryNavigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: Notification.Name("DirectionViewDismissed"), object: nil, userInfo: nil)
                
            guard let secondDestionation, firstDestionation == nil else { return }
            let userInfo = ["place" : secondDestionation]
            NotificationCenter.default.post(name: Notification.selectedPlace, object: nil, userInfo: userInfo)
        }
        
        if let firstDestionation {
            controller.firstDestionation = DirectionTextFieldModel(placeName: firstDestionation.placeName ?? "", placeAddress: firstDestionation.placeAddress, lat: firstDestionation.placeLat, long: firstDestionation.placeLong)
        }
        
        // check if we have secondDestination, it means that we should set
        // first location as my current location
        if let secondDestionation {
            if controller.firstDestionation == nil, let lat, let long {
                controller.firstDestionation = DirectionTextFieldModel(placeName: "My Location", placeAddress: nil, lat: lat, long: long)
            }
            
            controller.secondDestionation = DirectionTextFieldModel(placeName: secondDestionation.placeName ?? "", placeAddress: secondDestionation.placeAddress, lat: secondDestionation.placeLat, long: secondDestionation.placeLong)
        }
        
        controller.userLocation = (lat, long)
        controller.modalPresentationStyle = .pageSheet
        controller.isModalInPresentation = true
        controller.isRoutingOptionsEnabled = isRouteOptionEnabled ?? false
        
        supplementaryNavigationController?.pushViewController(controller, animated: true)
        splitDelegate?.showSupplementary()
    }
   
    func showSearchSceneWith(lat: Double?, long: Double?) {
        let controller = SearchVCBuilder.create()
        controller.userLocation = (lat, long)
        splitDelegate?.showSupplementary()
        
        supplementaryNavigationController?.popToRootViewController(animated: true)
        splitDelegate?.showSupplementary()
    }
    
    func showPoiCardScene(cardData: [MapModel], lat: Double?, long: Double?) {
        let controller = POICardVCBuilder.create(cardData: cardData, lat: lat, long: long)
        controller.delegate = self
        controller.userLocation = (lat, long)
        
        supplementaryNavigationController?.pushViewController(controller, animated: true)
        splitDelegate?.showSupplementary()
    }
    
    func showNavigationview(steps: [NavigationSteps], summaryData: (totalDistance: Double, totalDuration: Double), firstDestionation: MapModel?, secondDestionation: MapModel?) {
        let controller = NavigationBuilder.create(steps: steps, summaryData: summaryData, firstDestionation: firstDestionation, secondDestionation: secondDestionation)
        controller.delegate = self
        
        supplementaryNavigationController?.pushViewController(controller, animated: true)
        splitDelegate?.showSupplementary()
    }
    
    func showLoginFlow() {
        (UIApplication.shared.delegate as? AppDelegate)?.navigationController = splitViewController.navigationController
        
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
        (UIApplication.shared.delegate as? AppDelegate)?.navigationController = splitViewController.navigationController
        
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
    
    func showWelcome() {
        let controller = WelcomeVCBuilder.create()
        controller.modalPresentationStyle = .pageSheet
        
        controller.continueHandler = { [weak self] in
            self?.splitViewController.dismiss(animated: true)
        }
        
        splitViewController.present(controller, animated: true)
    }
    
    //close
    func closePOICardScene() {
        supplementaryNavigationController?.popViewController(animated: true)
    }
    
    func dismissSearchScene() {
        splitDelegate?.showOnlySecondary()
    }
}

private extension SplitViewExploreMapCoordinator {
    func showExploreScene() {
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
