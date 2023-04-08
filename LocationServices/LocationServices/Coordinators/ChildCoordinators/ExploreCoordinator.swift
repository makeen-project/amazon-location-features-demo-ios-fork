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
    var isiPad = UIDevice.current.userInterfaceIdiom == .pad
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showExploreScene()
    }
}

extension ExploreCoordinator: ExploreNavigationDelegate {
    func dismissSearchScene() {
        self.navigationController.dismiss(animated: true)
    }
    
    func showMapStyles() {
        dismissSearchScene()
        let controller = ExploreMapStyleBuilder.create()
        
        controller.modalPresentationStyle = .pageSheet
        controller.isModalInPresentation = true
        controller.dismissHandler = { [weak self] in
            self?.navigationController.dismiss(animated: true)
        }
        if let sheet = controller.sheetPresentationController {
            
            if isiPad {
                sheet.detents = [.medium(), .large()]
            } else {
                sheet.detents = [getCollapsedDetent(), .medium(), .large()]
            }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 10
        }
        
        navigationController.present(controller, animated: true)
    }
    
    func showDirections(isRouteOptionEnabled: Bool?,
                        firstDestionation: MapModel?,
                        secondDestionation: MapModel?,
                        lat: Double?,
                        long: Double?
    ) {
        self.dismissSearchScene()
        let controller = DirectionVCBuilder.create()
        controller.dismissHandler = { [weak self] in
            self?.navigationController.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name("DirectionViewDismissed"), object: nil, userInfo: nil)
                
                guard let secondDestionation, firstDestionation == nil else { return }
                let userInfo = ["place" : secondDestionation]
                NotificationCenter.default.post(name: Notification.selectedPlace, object: nil, userInfo: userInfo)
            })
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
        
        if let sheet = controller.sheetPresentationController {
            let mediumId = DirectionVC.Constants.mediumId
            let mediumDetent = UISheetPresentationController.Detent.custom(identifier: mediumId) { [weak controller] context in
                let bottomSafeArea = controller?.view.safeAreaInsets.bottom ?? 0
                let iPadHeight = UIScreen.main.bounds.height * 0.38 - bottomSafeArea
                let iPhoneHeight = UIScreen.main.bounds.height * 0.5 - bottomSafeArea
                
                return self.isiPad ? iPadHeight : iPhoneHeight
            }
            
            if isiPad {
                sheet.detents = [mediumDetent, .large()]
            } else {
                sheet.detents = [getCollapsedDetent(), mediumDetent, .large()]
            }
            sheet.selectedDetentIdentifier = isiPad ? .medium : .large
            
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .large
            sheet.selectedDetentIdentifier = mediumId
            sheet.preferredCornerRadius = 10
        }
        
        navigationController.present(controller, animated: true)
    }
   
    func showSearchSceneWith(lat: Double?, long: Double?) {
        let controller = SearchVCBuilder.create()
        controller.userLocation = (lat, long)
        controller.modalPresentationStyle = isiPad ? .formSheet : .pageSheet
        
        if let sheet = controller.sheetPresentationController {
            if isiPad {
                sheet.detents = [.medium(), .large()]
            } else {
                sheet.detents = [getCollapsedDetent(), .medium(), .large()]
            }
            sheet.selectedDetentIdentifier = isiPad ? .medium : .large
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.selectedDetentIdentifier = .medium
            sheet.preferredCornerRadius = 10
        }
        
        navigationController.present(controller, animated: true)
    }
    
    func showPoiCardScene(cardData: [MapModel], lat: Double?, long: Double?) {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            let controller = POICardVCBuilder.create(cardData: cardData, lat: lat, long: long)
            controller.delegate = self
            controller.userLocation = (lat, long)
            controller.modalPresentationStyle = .pageSheet
            controller.isModalInPresentation = true
            if let sheet = controller.sheetPresentationController {
                let smallId = UISheetPresentationController.Detent.Identifier("small")
                let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallId) { context in
                    return POICardVC.DetentsSizeClass.allInfo.height
                }
                
                if self.isiPad {
                    sheet.detents = [smallDetent]
                } else {
                    sheet.detents = [self.getCollapsedDetent(), smallDetent]
                }
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.largestUndimmedDetentIdentifier = smallId
                sheet.selectedDetentIdentifier = smallId
                sheet.preferredCornerRadius = 10
            }
            
            self.navigationController.present(controller, animated: true)
        }
    }
    
    func showDirectionScene() {
        
    }
    
    func showNavigationview(steps: [NavigationSteps], summaryData: (totalDistance: Double, totalDuration: Double), firstDestionation: MapModel?, secondDestionation: MapModel?) {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            let controller = NavigationBuilder.create(steps: steps, summaryData: summaryData, firstDestionation: firstDestionation, secondDestionation: secondDestionation)
            controller.delegate = self
            
            controller.modalPresentationStyle = .pageSheet
            controller.isModalInPresentation = true
            if let sheet = controller.sheetPresentationController {
                sheet.detents = [self.getCollapsedDetent(), .medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.largestUndimmedDetentIdentifier = self.getCollapsedDetentId()
                sheet.preferredCornerRadius = 10
                sheet.prefersGrabberVisible = true
            }
            
            self.navigationController.present(controller, animated: true)
        }
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
    
    func showWelcome() {
        let controller = WelcomeVCBuilder.create()
        controller.modalPresentationStyle = .pageSheet
        
        controller.continueHandler = { [weak self] in
            self?.navigationController.dismiss(animated: true)
        }
        
        navigationController.present(controller, animated: true)
    }
}

private extension ExploreCoordinator {
    func showExploreScene() {
        let controller = ExploreVCBuilder.create()
        controller.delegate = self
        controller.geofenceHandler =  {
            self.geofenceHandler?()
        }
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
