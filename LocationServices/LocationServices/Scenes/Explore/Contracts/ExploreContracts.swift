//
//  ExploreContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import UIKit


protocol ExploreViewModelProtocol: AnyObject {
    var delegate: ExploreViewModelOutputDelegate? { get set }
    func login()
    func logout()
    
    func activateRoute(route: RouteModel)
    func deactivateRoute()
    func userLocationChanged(_ userLocation: CLLocationCoordinate2D)
    func loadPlace(for coordinates: CLLocationCoordinate2D, userLocation: CLLocationCoordinate2D?) async
    func shouldShowWelcome() -> Bool
}

protocol ExploreViewModelOutputDelegate: AnyObject, AlertPresentable {
    func loginCompleted(_ presentation: ExplorePresentation)
    func logoutCompleted()
    
    func routeReCalculated(route: DirectionPresentation, departureLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, routeType: RouteTypes)
    func userReachedDestination(_ destination: MapModel)
    func showAnnotation(model: SearchPresentation, force: Bool)
}

protocol ExploreVCProtocol: AnyObject {
    var delegate: ExploreNavigationDelegate? { get set }
}

protocol ExploreNavigationDelegate: AnyObject {
    func showMapStyles()
    func showDirections(isRouteOptionEnabled: Bool?,
                        firstDestionation: MapModel?,
                        secondDestionation: MapModel?,
                        lat: Double?,
                        long: Double?)
    func showSearchSceneWith(lat: Double?, long: Double?)
    func showPoiCardScene(cardData: [MapModel], lat: Double?, long: Double?)
    func showNavigationview(steps: [RouteNavigationStep], summaryData: (totalDistance: Double, totalDuration: Double), firstDestionation: MapModel?, secondDestionation: MapModel?)
    func showLoginFlow()
    func showLoginSuccess()
    func showAttribution()
    func showWelcome()
    
    func dismissSearchScene()
    func closePOICardScene()
    func closeNavigationScene()
    
    func hideNavigationScene()
}

protocol ExploreViewDelegate: AnyObject {
    var delegate: ExploreViewOutputDelegate? { get set }
    func getUserLocation()
}

protocol ExploreViewOutputDelegate: AnyObject, BottomSheetPresentable {
    func loginButtonTapped()
    func searchTextTapped(userLocation: CLLocationCoordinate2D?)
    func showPoiCard(cardData: [MapModel])
    func showDirectionView(userLocation: CLLocationCoordinate2D?)
    func getBottomSafeAreaWithTabBarHeight() -> CGFloat
    func userLocationChanged(_ userLocation: CLLocationCoordinate2D)
    func performLocationDependentAction(_ action: ()->())
    func showMapStyles()
    func showPoiCard(for location: CLLocationCoordinate2D)
    func showAttribution()
}

protocol BottomSheetPresentable: AnyObject {
    func getBottomSheetHeight() -> CGFloat
}

extension BottomSheetPresentable where Self: UIViewController {
    func getBottomSheetHeight() -> CGFloat {
        return self.presentedViewController?.view.frame.height ?? 0
    }
}
