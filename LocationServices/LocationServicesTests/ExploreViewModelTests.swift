//
//  ExploreViewModelTests.swift
//  ExploreViewModelTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices
import CoreLocation

final class ExploreViewModelTests: XCTestCase {

    let exploreViewModel = ExploreViewModel(routingService: RoutingAPIService(), locationService: LocationService())
    var departureLocation: CLLocationCoordinate2D!
    var destinationLocation: CLLocationCoordinate2D!
    var routeModel: RouteModel!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
        
        departureLocation  = CLLocationCoordinate2D(latitude: 40.75790965683081, longitude: -73.98559624758715)
        destinationLocation = CLLocationCoordinate2D(latitude:40.75474012009525, longitude: -73.98387963388527)
        routeModel = RouteModel(departurePosition: departureLocation, destinationPosition: destinationLocation, travelMode: RouteTypes.car, avoidFerries: false, avoidTolls: false, isPreview: true, departurePlaceName: "Time Square", departurePlaceAddress: "Manhattan, NY 10036, United States", destinationPlaceName: "CUNY Graduate Center", destinationPlaceAddress: "365 5th Ave, New York, NY 10016, United States")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testActivateRoute() throws {
       exploreViewModel.activateRoute(route: routeModel)
       XCTAssertEqual(exploreViewModel.isSelectedRouteHasValue(), true, "Expected true")
    }
    
    func testDeactivateRoute() throws {
       exploreViewModel.deactivateRoute()
       XCTAssertEqual(exploreViewModel.isSelectedRouteHasValue(), false, "Expected true")
    }
    
    func testUserLocationChangedWithoutSelectedRoute() throws {
        let delegate = MockExploreViewModelOutputDelegate()
        exploreViewModel.delegate = delegate
        
        let myDelegateExpectation = expectation(description: "The delegate method was called")
        exploreViewModel.userLocationChanged(departureLocation)
        
        // Wait for myDelegateFunction to be called
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            myDelegateExpectation.fulfill()
        }
        
        wait(for: [myDelegateExpectation], timeout: 10)
        
        XCTAssertEqual(delegate.isUserReachedDestination, false, "Expected isUserReachedDestination false")
    }
    
    func testUserLocationChangedWithSelectedRoute() throws {
        let delegate = MockExploreViewModelOutputDelegate()
        exploreViewModel.delegate = delegate
        
        let myDelegateExpectation = expectation(description: "The delegate method was called")
        exploreViewModel.activateRoute(route: routeModel)
        exploreViewModel.userLocationChanged(destinationLocation)
        
        // Wait for myDelegateFunction to be called
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            myDelegateExpectation.fulfill()
        }
        
        wait(for: [myDelegateExpectation], timeout: 10)
        
        XCTAssertEqual(delegate.isUserReachedDestination, true, "Expected isUserReachedDestination true")
    }

    func testReCalculateRouteReturnSuccess() throws {
        let delegate = MockExploreViewModelOutputDelegate()
        exploreViewModel.delegate = delegate
        
        let myDelegateExpectation = expectation(description: "The delegate method was called")
        exploreViewModel.activateRoute(route: routeModel)
        exploreViewModel.reCalculateRoute(with: destinationLocation)
        
        // Wait for myDelegateFunction to be called
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            myDelegateExpectation.fulfill()
        }
        
        wait(for: [myDelegateExpectation], timeout: 10)
        
        XCTAssertEqual(delegate.isRouteReCalculated, true, "Expected isRouteReCalculated true")
    }
    
    func testReCalculateRouteReturnFailure() throws {
        let delegate = MockExploreViewModelOutputDelegate()
        exploreViewModel.delegate = delegate
        
        let myDelegateExpectation = expectation(description: "The delegate method was called")
        exploreViewModel.reCalculateRoute(with: destinationLocation)
        
        // Wait for myDelegateFunction to be called
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            myDelegateExpectation.fulfill()
        }
        
        wait(for: [myDelegateExpectation], timeout: 5)
        
        XCTAssertEqual(delegate.isRouteReCalculated, false, "Expected isRouteReCalculated false")
    }
    
    func testLoadPlaceSuccess() throws {
        let delegate = MockExploreViewModelOutputDelegate()
        exploreViewModel.delegate = delegate
        
        let myDelegateExpectation = expectation(description: "The delegate method was called")

        exploreViewModel.loadPlace(for: destinationLocation, userLocation: departureLocation)
        
        // Wait for myDelegateFunction to be called
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            myDelegateExpectation.fulfill()
        }
        
        wait(for: [myDelegateExpectation], timeout: 10)

        XCTAssertEqual(delegate.hasAnnotationShown, true, "Expected hasAnnotationShown true")
    }
    
    func testLoadPlaceFailure() throws {
        let delegate = MockExploreViewModelOutputDelegate()
        exploreViewModel.delegate = delegate
        
        let myDelegateExpectation = expectation(description: "The delegate method was called")

        exploreViewModel.loadPlace(for: destinationLocation, userLocation: nil)
        
        // Wait for myDelegateFunction to be called
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            myDelegateExpectation.fulfill()
        }
        
        wait(for: [myDelegateExpectation], timeout: 3)

        XCTAssertEqual(delegate.hasAnnotationShown, false, "Expected hasAnnotationShown false")
    }

    func testShouldShowWelcomeWithEmptyStorage() throws {
        XCTAssertEqual(exploreViewModel.shouldShowWelcome(), true, "Expected shouldShowWelcome true")
    }
    
    func testShouldShowWelcomeWithCurrentVersion() throws {
        let currentVersion = UIApplication.appVersion()
        UserDefaultsHelper.save(value: currentVersion, key: .termsAndConditionsAgreedVersion)
        XCTAssertEqual(exploreViewModel.shouldShowWelcome(), false, "Expected shouldShowWelcome false")
    }
    
    func testShouldShowWelcomeWithDifferentVersion() throws {
        UserDefaultsHelper.save(value: "0.0", key: .termsAndConditionsAgreedVersion)
        XCTAssertEqual(exploreViewModel.shouldShowWelcome(), true, "Expected shouldShowWelcome true")
    }
}

class MockExploreViewModelOutputDelegate : ExploreViewModelOutputDelegate {
    var isLoginCompleted = false
    var isLogoutCompleted = false
    var isRouteReCalculated = false
    var isUserReachedDestination = false
    var hasAnnotationShown = false
    var hasAlertShown = false
    
    func loginCompleted(_ presentation: LocationServices.ExplorePresentation) {
        isLoginCompleted = true
    }
    
    func logoutCompleted() {
        isLogoutCompleted = true
    }
    
    func routeReCalculated(route: LocationServices.DirectionPresentation, departureLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, routeType: LocationServices.RouteTypes) {
        self.isRouteReCalculated = true
    }
    
    func userReachedDestination(_ destination: LocationServices.MapModel) {
        self.isUserReachedDestination = true
    }
    
    func showAnnotation(model: LocationServices.SearchPresentation) {
        self.hasAnnotationShown = true
    }
    
    func showAlert(_ model: LocationServices.AlertModel) {
        self.hasAlertShown = true
    }
    
    
}
