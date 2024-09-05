//
//  ExploreViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices
import CoreLocation
import AWSLocation

final class ExploreViewModelTests: XCTestCase {

    var routingService: RoutingAPIServiceMock!
    var locationService: LocationAPIServiceMock!
    var exploreViewModel: ExploreViewModel!
    var departureLocation: CLLocationCoordinate2D!
    var destinationLocation: CLLocationCoordinate2D!
    var routeModel: RouteModel!
    var delegate: MockExploreViewModelOutputDelegate!
    var userLocation: (lat: Double, long: Double)!
    var search: SearchPresentation!
    enum Constants {
        static let waitRequestDuration: TimeInterval = 10
        static let apiRequestDuration: TimeInterval = 1
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
        
        routingService = RoutingAPIServiceMock(delay: Constants.apiRequestDuration)
        locationService = LocationAPIServiceMock(delay: Constants.apiRequestDuration)
        exploreViewModel = ExploreViewModel(routingService: routingService, locationService: locationService)
        delegate = MockExploreViewModelOutputDelegate()
        exploreViewModel.delegate = delegate
        userLocation = (lat: 40.7487776237092, long: -73.98554260340953)
        search = SearchPresentation(placeId: "myLocation",
                                       fullLocationAddress: "Times Square, New York",
                                       distance: nil,
                                       countryName: nil,
                                       cityName: nil,
                                       placeLat: userLocation?.lat,
                                       placeLong: userLocation?.long,
                                       name: "Times Square")
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
        exploreViewModel.delegate = delegate
        
        XCTWaiter().wait(until: {
            return !self.delegate.hasUserReachedDestination
        }, timeout: Constants.waitRequestDuration, message: "Expected hasUserReachedDestination false")
    }
    
    func testUserLocationChangedWithSelectedRoute() throws {
        exploreViewModel.activateRoute(route: routeModel)
        exploreViewModel.userLocationChanged(destinationLocation)

        XCTWaiter().wait(until: {
            return self.delegate.hasUserReachedDestination
        }, timeout: Constants.waitRequestDuration, message: "Expected hasUserReachedDestination true")
        
        XCTAssertEqual(delegate.hasUserReachedDestination, true, "Expected isUserReachedDestination true")
    }

    func testReCalculateRouteReturnSuccess() async throws {
        let direction = DirectionPresentation(model:CalculateRouteOutput(), travelMode: .car)
        locationService.mockGetPlaceResult = .success(search)
        locationService.mockSearchWithPositionResult = .success([search])
        routingService.putResult = [LocationClientTypes.TravelMode.car: .success(direction)]
        exploreViewModel.activateRoute(route: routeModel)
        try await exploreViewModel.reCalculateRoute(with: destinationLocation)
        
        XCTWaiter().wait(until: {
            return self.delegate.isRouteReCalculated
        }, timeout: Constants.waitRequestDuration, message: "Expected isRouteReCalculated true")
    }
    
    func testReCalculateRouteReturnFailure() async throws {
        try await exploreViewModel.reCalculateRoute(with: destinationLocation)
        
        XCTWaiter().wait(until: {
            return !self.delegate.isRouteReCalculated
        }, timeout: Constants.waitRequestDuration, message: "Expected isRouteReCalculated true")
    }
    
    func testLoadPlaceSuccess() async throws {
        let search = SearchPresentation(placeId: "myLocation",
                                       fullLocationAddress: "My Location",
                                       distance: nil,
                                       countryName: nil,
                                       cityName: nil,
                                       placeLat: departureLocation?.latitude,
                                       placeLong: departureLocation?.longitude,
                                       name: "My Location")
        locationService.mockSearchWithPositionResult = .success([search])
        await exploreViewModel.loadPlace(for: destinationLocation, userLocation: departureLocation)
        
        XCTWaiter().wait(until: {
            return !self.delegate.hasAnnotationShown
        }, timeout: Constants.waitRequestDuration, message: "Expected hasAnnotationShown true")
    }
    
    func testLoadPlaceFailure() async throws {
        await exploreViewModel.loadPlace(for: destinationLocation, userLocation: nil)
        
        XCTWaiter().wait(until: {
            return !self.delegate.hasAnnotationShown
        }, timeout: Constants.waitRequestDuration, message: "Expected hasAnnotationShown true")
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
    var hasUserReachedDestination = false
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
        self.hasUserReachedDestination = true
    }
    
    func showAnnotation(model: LocationServices.SearchPresentation) {
        self.hasAnnotationShown = true
    }
    
    func showAnnotation(model: LocationServices.SearchPresentation, force: Bool) {
        self.hasAnnotationShown = true
    }
    
    func showAlert(_ model: LocationServices.AlertModel) {
        self.hasAlertShown = true
    }
    
    
}
