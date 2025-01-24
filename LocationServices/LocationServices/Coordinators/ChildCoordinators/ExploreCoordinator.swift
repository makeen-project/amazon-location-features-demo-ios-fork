//
//  ExploreCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import AWSGeoRoutes

final class ExploreCoordinator: Coordinator {
    var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .explore }
    var geofenceHandler: VoidHandler?
    weak var currentBottomSheet:UIViewController?
    var isiPad = UIDevice.current.userInterfaceIdiom == .pad
    
    private let searchScreenStyle = SearchScreenStyle(backgroundColor: .searchBarBackgroundColor, searchBarStyle: SearchBarStyle(backgroundColor: .searchBarBackgroundColor, textFieldBackgroundColor: .white))
    private let directionScreenStyle = DirectionScreenStyle(backgroundColor: .searchBarBackgroundColor)
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showExploreScene()
    }
}

extension ExploreCoordinator: ExploreNavigationDelegate {
    func dismissSearchScene() {
        currentBottomSheet?.dismissBottomSheet()
        NotificationCenter.default.post(name: Notification.Name("updateMapViewButtons"), object: nil, userInfo: nil)
    }
    
    func showMapStyles() {
        dismissSearchScene()
        let controller = ExploreMapStyleBuilder.create()

        controller.dismissHandler = { [weak self] in
            self?.currentBottomSheet?.dismissBottomSheet()
            NotificationCenter.default.post(name: Notification.Name("updateMapViewButtons"), object: nil, userInfo: nil)
        }
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: TabBarCoordinator.tabBarController!)
        controller.setBottomSheetHeight(to: 600)
        currentBottomSheet = controller
        NotificationCenter.default.post(name: Notification.updateMapLayerItems, object: nil, userInfo: ["height": 500])
    }
    
    func showDirections(isRouteOptionEnabled: Bool?,
                        firstDestination: MapModel?,
                        secondDestination: MapModel?,
                        lat: Double?,
                        long: Double?
    ) {
        self.dismissSearchScene()
        let controller = DirectionVCBuilder.create()
        controller.isInSplitViewController = false
        controller.directionScreenStyle = directionScreenStyle
        controller.dismissHandler = { [weak self] in
            self?.currentBottomSheet?.dismissBottomSheet()
            
            NotificationCenter.default.post(name: Notification.Name("DirectionViewDismissed"), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: Notification.Name("updateMapViewButtons"), object: nil, userInfo: nil)
            guard let secondDestination, firstDestination == nil else { return }
            let userInfo = ["place" : secondDestination]
            NotificationCenter.default.post(name: Notification.selectedPlace, object: nil, userInfo: userInfo)
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
        controller.isRoutingOptionsEnabled = isRouteOptionEnabled ?? false
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: TabBarCoordinator.tabBarController!)
        let minHeight = 0.2
        let mediumHeight = 0.69
        controller.enableBottomSheetGrab(smallHeight: minHeight, mediumHeight: mediumHeight)
        
        NotificationCenter.default.post(name: Notification.updateMapLayerItems, object: nil, userInfo: ["height": controller.getMediumDetentHeight()])
        currentBottomSheet = controller
    }
    
    func showSearchSceneWith(lat: Double?, long: Double?) {
        let controller = SearchVCBuilder.create()
        controller.delegate = self
        controller.userLocation = (lat, long)
        controller.searchScreenStyle = searchScreenStyle
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: TabBarCoordinator.tabBarController!)
        controller.enableBottomSheetGrab(largeHeight: 1)
        currentBottomSheet = controller
    }
    
    func showSearchScene() {
        let controller = SearchVCBuilder.create()
        
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: TabBarCoordinator.tabBarController!)
        controller.enableBottomSheetGrab()
        currentBottomSheet = controller
    }
    
    func showPoiCardScene(cardData: [MapModel], lat: Double?, long: Double?) {
        let controller = POICardVCBuilder.create(cardData: cardData, lat: lat, long: long)
        controller.delegate = self
        controller.userLocation = (lat, long)
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: TabBarCoordinator.tabBarController!)
        controller.setBottomSheetHeight(to: 450)
        currentBottomSheet = controller
    }
    
    func showArrivalCardScene(route: RouteModel) {
        let controller = ArrivalCardVCBuilder.create(route: route)
        controller.delegate = self
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: TabBarCoordinator.tabBarController!)
        controller.setBottomSheetHeight(to: 200)
        currentBottomSheet = controller
    }
    
    func showDirectionScene() {
        
    }
    
    func showNavigationview(route: GeoRoutesClientTypes.Route, firstDestination: MapModel?, secondDestination: MapModel?) {
            let controller = NavigationBuilder.create(route: route, firstDestination: firstDestination, secondDestination: secondDestination)
            controller.delegate = self
            
            currentBottomSheet?.dismissBottomSheet()
            controller.presentBottomSheet(parentController: TabBarCoordinator.tabBarController!)
            let minHeight = 0.18
            controller.enableBottomSheetGrab(smallHeight: minHeight)
            currentBottomSheet = controller
    }
    
    func showLoginFlow() {
        (UIApplication.shared.delegate as? AppDelegate)?.navigationController = navigationController
        
        let controller = LoginVCBuilder.create()
        controller.dismissHandler = { [weak self] in
            self?.navigationController.dismiss(animated: true)
            NotificationCenter.default.post(name: Notification.Name("updateMapViewButtons"), object: nil, userInfo: nil)
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
                NotificationCenter.default.post(name: Notification.Name("updateMapViewButtons"), object: nil, userInfo: nil)
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
            self?.navigationController.navigationBar.isHidden = true
        }
        navigationController.pushViewController(controller, animated: true)
    }
    
    func showWelcome() {
        let controller = WelcomeVCBuilder.create()
        controller.modalPresentationStyle = .pageSheet
        
        controller.continueHandler = { [weak self] in
            self?.navigationController.dismiss(animated: true)
        }
        
        navigationController.present(controller, animated: true)
    }
    
    //close
    func closePOICardScene() {
        navigationController.dismiss(animated: true)
    }
    
    func closeNavigationScene() {
        NotificationCenter.default.post(name: Notification.Name("NavigationViewDismissed"), object: nil, userInfo: nil)
    }
    
    func hideNavigationScene() {
        navigationController.dismiss(animated: true)
    }
}

private extension ExploreCoordinator {
    static var exploreController: ExploreVC?
    func showExploreScene() {
        let controller = ExploreVCBuilder.create()
        controller.delegate = self
        controller.applyStyles(style: searchScreenStyle)
        controller.geofenceHandler = {
            self.geofenceHandler?()
        }
        ExploreCoordinator.exploreController = controller
        navigationController.pushViewController(controller, animated: true)
    }
    
    func getCollapsedDetent() -> UISheetPresentationController.Detent {
        return UISheetPresentationController.Detent.custom(identifier: getCollapsedDetentId()) { context in
            let tabBarHeight = self.navigationController.tabBarController?.tabBar.frame.height ?? 0
            let bottomSafeAreaHeight = self.navigationController.view.safeAreaInsets.bottom
            let minimumBottomSheetHeight: CGFloat = 76
            return tabBarHeight - bottomSafeAreaHeight + minimumBottomSheetHeight
        }
    }
    
    func getCollapsedDetentId() -> UISheetPresentationController.Detent.Identifier {
        return UISheetPresentationController.Detent.Identifier("collapsed")
    }
}
