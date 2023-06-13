//
//  ExploreCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

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
    }
    
    func showMapStyles() {
        dismissSearchScene()
        let controller = ExploreMapStyleBuilder.create()

        controller.dismissHandler = { [weak self] in
            self?.currentBottomSheet?.dismissBottomSheet()
        }
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: ExploreCoordinator.exploreController!)
        controller.enableBottomSheetGrab()
        currentBottomSheet = controller
    }
    
    func showDirections(isRouteOptionEnabled: Bool?,
                        firstDestionation: MapModel?,
                        secondDestionation: MapModel?,
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
            
            guard let secondDestionation, firstDestionation == nil else { return }
            let userInfo = ["place" : secondDestionation]
            NotificationCenter.default.post(name: Notification.selectedPlace, object: nil, userInfo: userInfo)
        }
        
        if let firstDestionation {
            controller.firstDestionation = DirectionTextFieldModel(placeName: firstDestionation.placeName ?? "", placeAddress: firstDestionation.placeAddress, lat: firstDestionation.placeLat, long: firstDestionation.placeLong)
        }

        // first location as my current location
        if controller.firstDestionation == nil, let lat, let long {
            controller.firstDestionation = DirectionTextFieldModel(placeName: "My Location", placeAddress: nil, lat: lat, long: long)
        }        

        if let secondDestionation {
            controller.secondDestionation = DirectionTextFieldModel(placeName: secondDestionation.placeName ?? "", placeAddress: secondDestionation.placeAddress, lat: secondDestionation.placeLat, long: secondDestionation.placeLong)
        }
        
        controller.userLocation = (lat, long)
        controller.isRoutingOptionsEnabled = isRouteOptionEnabled ?? false
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: ExploreCoordinator.exploreController!)
        controller.enableBottomSheetGrab()
        currentBottomSheet = controller
    }
    
    func showSearchSceneWith(lat: Double?, long: Double?) {
        let controller = SearchVCBuilder.create()
        controller.delegate = self
        controller.userLocation = (lat, long)
        controller.searchScreenStyle = searchScreenStyle
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: ExploreCoordinator.exploreController!)
        controller.enableBottomSheetGrab()
        currentBottomSheet = controller
    }
    
    func showSearchScene() {
        let controller = SearchVCBuilder.create()
        
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: ExploreCoordinator.exploreController!)
        controller.enableBottomSheetGrab()
        currentBottomSheet = controller
    }
    
    func showPoiCardScene(cardData: [MapModel], lat: Double?, long: Double?) {
        let controller = POICardVCBuilder.create(cardData: cardData, lat: lat, long: long)
        controller.delegate = self
        controller.userLocation = (lat, long)
        currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: ExploreCoordinator.exploreController!)
        controller.setBottomSheetHeight(to: 200)
        currentBottomSheet = controller
    }
    
    func showDirectionScene() {
        
    }
    
    func showNavigationview(steps: [NavigationSteps], summaryData: (totalDistance: Double, totalDuration: Double), firstDestionation: MapModel?, secondDestionation: MapModel?) {
            let controller = NavigationBuilder.create(steps: steps, summaryData: summaryData, firstDestionation: firstDestionation, secondDestionation: secondDestionation)
            controller.delegate = self
            
            currentBottomSheet?.dismissBottomSheet()
        controller.presentBottomSheet(parentController: ExploreCoordinator.exploreController!)
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
