//
//  SplitViewExploreMapCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import AWSGeoRoutes

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
    private var isSearchHidden = false
    
    private let searchScreenStyle = SearchScreenStyle(backgroundColor: .white, searchBarStyle: SearchBarStyle(backgroundColor: .clear, textFieldBackgroundColor: .lsLight2))
    private let directionScreenStyle = DirectionScreenStyle(backgroundColor: .white)
    
    private lazy var supplementaryController: SearchVC = {
        let controller = SearchVCBuilder.create()
        controller.delegate = self
        controller.searchScreenStyle = searchScreenStyle
        return controller
    }()
    
    private lazy var secondaryController: ExploreVC = {
        let controller = ExploreVCBuilder.create()
        controller.delegate = self
        controller.splitDelegate = self
        controller.applyStyles(style: searchScreenStyle)
        controller.geofenceHandler = {
            self.geofenceHandler?()
        }
        
        floatingView = MapFloatingViewHandler(viewController: controller)
        floatingView?.delegate = self
        floatingView?.setupNavigationSearch(state: .onlySecondaryVisible)
        return controller
    }()
    
    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }

    func start() {
        showExploreScene()
    }
    
    func displayModeChanged(displayMode: UISplitViewController.DisplayMode) {
        let searchState: MapSearchState = isSearchHidden ? .hidden : displayMode.mapSearchState()
        floatingView?.setupNavigationSearch(state: searchState, hideSearch: true)
        
        let routeButtonState: RouteButtonState = displayMode.isOnlySecondary ? .showRoute : .hideRoute
        secondaryController.mapNavigationActionsView.updateRouteButton(state: routeButtonState)
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
                        firstDestination: MapModel?,
                        secondDestination: MapModel?,
                        lat: Double?,
                        long: Double?
    ) {
        let controller = DirectionVCBuilder.create()
        controller.isInSplitViewController = true
        controller.directionScreenStyle = directionScreenStyle
        controller.dismissHandler = { [weak self] in
            NotificationCenter.default.post(name: Notification.directionViewDismissed, object: nil, userInfo: nil)
            self?.supplementaryNavigationController?.popViewController(animated: true)
        }
        
        if let firstDestination {
            controller.firstDestination = DirectionTextFieldModel(placeName: firstDestination.placeName ?? "", placeAddress: firstDestination.placeAddress, lat: firstDestination.placeLat, long: firstDestination.placeLong)
        }
        
        // first location as my current location
        if controller.firstDestination == nil, let lat, let long {
            controller.firstDestination = DirectionTextFieldModel(placeName: "My Location", placeAddress: nil, lat: lat, long: long)
        }

        if let secondDestination {
            controller.secondDestination = DirectionTextFieldModel(placeName: secondDestination.placeName ?? "", placeAddress: secondDestination.placeAddress, lat: secondDestination.placeLat, long: secondDestination.placeLong)
        }
        
        controller.userLocation = (lat, long)
        controller.modalPresentationStyle = .pageSheet
        controller.isModalInPresentation = true
        controller.isRoutingOptionsEnabled = isRouteOptionEnabled ?? false
        
        supplementaryNavigationController?.pushViewController(controller, animated: true)
        splitDelegate?.showSupplementary()
    }
   
    func showSearchSceneWith(lat: Double?, long: Double?) {
        let controller = supplementaryController
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
        
        //always show poi card after search and it should be only one in navigation stack
        if let viewControllers = supplementaryNavigationController?.viewControllers,
           viewControllers.count > 2,
           let firstController = viewControllers.first,
           let lastController = viewControllers.last {
            supplementaryNavigationController?.viewControllers = [firstController, lastController]
        }
        splitDelegate?.showSupplementary()
    }
    
    func showArrivalCardScene(route: RouteModel) {
        let controller = ArrivalCardVCBuilder.create(route: route)
        controller.delegate = self
        
        supplementaryNavigationController?.pushViewController(controller, animated: true)
        if let viewControllers = supplementaryNavigationController?.viewControllers,
           viewControllers.count > 2,
           let firstController = viewControllers.first,
           let lastController = viewControllers.last {
            supplementaryNavigationController?.viewControllers = [firstController, lastController]
        }
        splitDelegate?.showSupplementary()
    }
    
    func showNavigationview(route: GeoRoutesClientTypes.Route, firstDestination: MapModel?, secondDestination: MapModel?) {
        let controller = NavigationBuilder.create(route: route, firstDestination: firstDestination, secondDestination: secondDestination)
        controller.delegate = self
        
        isSearchHidden = true
        splitDelegate?.showOnlySecondary()
        supplementaryNavigationController?.pushViewController(controller, animated: false)
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
        let controller = AttributionVCBuilder.create()
        controller.closeCallback = { [weak self] in
            self?.supplementaryNavigationController?.popViewController(animated: true)
        }
        supplementaryNavigationController?.pushViewController(controller, animated: true)
        splitDelegate?.showSupplementary()
    }
    
    func showWelcome() {
        let controller = WelcomeVCBuilder.create()
        controller.modalPresentationStyle = .formSheet
        controller.isModalInPresentation = true
        
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
    
    func closeNavigationScene() {
        NotificationCenter.default.post(name: Notification.navigationViewDismissed, object: nil, userInfo: nil)
        supplementaryNavigationController?.popViewController(animated: true)
        isSearchHidden = false
        displayModeChanged(displayMode: splitViewController.displayMode)
        splitDelegate?.showSupplementary()
    }
    
    func hideNavigationScene() {
        splitDelegate?.showOnlySecondary()
    }
}

private extension SplitViewExploreMapCoordinator {
    func showExploreScene() {
        setSupplementary()
        setSecondary()
        secondaryController.navigationController?.navigationBar.isHidden = true
    }
    
    func setSupplementary() {
        updateSearchScreenLocation()
        splitViewController.setViewController(supplementaryController, for: .supplementary)
    }
    
    func setSecondary() {
        splitViewController.changeSecondaryViewController(to: secondaryController)
        splitViewController.show(.secondary)
    }
    
    func updateSearchScreenLocation() {
        supplementaryController.userLocation = (secondaryController.userCoreLocation?.latitude, secondaryController.userCoreLocation?.longitude)
    }
}

extension SplitViewExploreMapCoordinator: SplitViewVisibilityProtocol {
    func showPrimary() {
        splitDelegate?.showPrimary()
    }
    
    func showSupplementary() {
        updateSearchScreenLocation()
        splitDelegate?.showSupplementary()
    }
    
    func showOnlySecondary() {
        splitDelegate?.showOnlySecondary()
    }
    
    func showSearchScene() {
        let location = secondaryController.userCoreLocation
        showSearchSceneWith(lat: location?.latitude, long: location?.longitude)
    }
}
