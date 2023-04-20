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

    
}
