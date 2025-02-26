//
//  NavigationVCViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices
import AWSGeoRoutes

final class NavigationVCViewModelTests: XCTestCase {

    let firstDestination = MapModel(placeName: "Times Square", placeAddress: "Manhattan, NY 10036, United States", placeLat: 40.75804781268635, placeLong: -73.98554260340953)
    
    let secondDestination = MapModel(placeName: "CUNY Graduate Center", placeAddress: "365 5th Ave, New York, NY 10016, United States", placeLat: 40.7487776237092, placeLong: -73.98404872540857)
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testInitWithValidData() throws {
        let step = GeoRoutesClientTypes.RouteVehicleTravelStep(distance: 2, duration: 2, instruction: "continue", type: .continue)
        let legDetails = GeoRoutesClientTypes.RouteVehicleLegDetails(travelSteps: [step])
        let routeLegDetails = GeoRoutesClientTypes.RouteLeg(vehicleLegDetails: legDetails)
        let route = GeoRoutesClientTypes.Route(legs: [routeLegDetails])
        
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), route: route, firstDestination: firstDestination, secondDestination: secondDestination)
        XCTAssertEqual(navigationVCViewModel.firstDestination?.placeName, "Times Square", "Expected Times Square place name")
    }

    func testInitWithEmptySteps() throws {
        let legDetails = GeoRoutesClientTypes.RouteVehicleLegDetails(travelSteps: [])
        let routeLegDetails = GeoRoutesClientTypes.RouteLeg(vehicleLegDetails: legDetails)
        let route = GeoRoutesClientTypes.Route(legs: [routeLegDetails])
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), route: route, firstDestination: firstDestination, secondDestination: secondDestination)
        XCTAssertEqual(navigationVCViewModel.firstDestination?.placeName, "Times Square", "Expected Times Square place name")
    }
    
    func testInitWithStepsWithoutStreetNames() throws {
        let firstDestination = MapModel(placeName: "Times Square", placeAddress: nil, placeLat: 40.75804781268635, placeLong: -73.98554260340953)
        
        let secondDestination = MapModel(placeName: "CUNY Graduate Center", placeAddress: nil, placeLat: 40.7487776237092, placeLong: -73.98404872540857)
        let legDetails = GeoRoutesClientTypes.RouteVehicleLegDetails(travelSteps: [])
        let routeLegDetails = GeoRoutesClientTypes.RouteLeg(vehicleLegDetails: legDetails)
        let route = GeoRoutesClientTypes.Route(legs: [routeLegDetails])
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), route: route, firstDestination: firstDestination, secondDestination: secondDestination)
        XCTAssertEqual(navigationVCViewModel.firstDestination?.placeName, "Times Square", "Expected Times Square place name")
    }
    
    func testUpdateWithValidData() throws {
        var legDetails = GeoRoutesClientTypes.RouteVehicleLegDetails(travelSteps: [])
        var routeLegDetails = GeoRoutesClientTypes.RouteLeg(vehicleLegDetails: legDetails)
        var route = GeoRoutesClientTypes.Route(legs: [routeLegDetails])
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), route: route, firstDestination: firstDestination, secondDestination: secondDestination)

        let step = GeoRoutesClientTypes.RouteVehicleTravelStep(distance: 2, duration: 2, instruction: "continue", type: .continue)
        legDetails = GeoRoutesClientTypes.RouteVehicleLegDetails(travelSteps: [step])
        routeLegDetails = GeoRoutesClientTypes.RouteLeg(vehicleLegDetails: legDetails)
        route = GeoRoutesClientTypes.Route(legs: [routeLegDetails])
        navigationVCViewModel.update(route: route)
        XCTAssertEqual(navigationVCViewModel.route.legs?[0].vehicleLegDetails?.travelSteps?.first?.duration, 2, "Expected steps duration 2")
    }
    
    func testGetSummaryData() throws {
        var legDetails = GeoRoutesClientTypes.RouteVehicleLegDetails(travelSteps: [])
        var routeLegDetails = GeoRoutesClientTypes.RouteLeg(vehicleLegDetails: legDetails)
        var route = GeoRoutesClientTypes.Route(legs: [routeLegDetails])
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), route: route, firstDestination: firstDestination, secondDestination: secondDestination)

        let step = GeoRoutesClientTypes.RouteVehicleTravelStep(distance: 2, duration: 2, instruction: "continue", type: .continue)
        legDetails = GeoRoutesClientTypes.RouteVehicleLegDetails(travelSteps: [step])
        routeLegDetails = GeoRoutesClientTypes.RouteLeg(vehicleLegDetails: legDetails)
        route = GeoRoutesClientTypes.Route(legs: [routeLegDetails], summary: GeoRoutesClientTypes.RouteSummary(distance: 10, duration: 1, tolls: nil))
        navigationVCViewModel.update(route: route)
        
        XCTAssertEqual(navigationVCViewModel.getSummaryData().totalDistance, "0.01 mi", "Expected summary total distance 0.01 mi")
    }
    
    func testGetDataWithZeroSteps() throws {
        let legDetails = GeoRoutesClientTypes.RouteVehicleLegDetails(travelSteps: [])
        let routeLegDetails = GeoRoutesClientTypes.RouteLeg(vehicleLegDetails: legDetails)
        let route = GeoRoutesClientTypes.Route(legs: [routeLegDetails])
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), route: route, firstDestination: firstDestination, secondDestination: secondDestination)
        
        XCTAssertEqual(navigationVCViewModel.getData().count, 0, "Expected get data count")
    }
    
    func testGetDataWithOneStep() throws {
        let step = GeoRoutesClientTypes.RouteVehicleTravelStep(distance: 1, duration: 2, instruction: "continue", type: .continue)
        let legDetails = GeoRoutesClientTypes.RouteVehicleLegDetails(travelSteps: [step])
        let routeLegDetails = GeoRoutesClientTypes.RouteLeg(vehicleLegDetails: legDetails)
        let route = GeoRoutesClientTypes.Route(legs: [routeLegDetails])
        
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), route: route, firstDestination: firstDestination, secondDestination: secondDestination)
        XCTAssertEqual(navigationVCViewModel.getData().count, 0, "Expected get data count")
    }
    
    
    func testGetDataWithMultipleSteps() throws {
        let step1 = GeoRoutesClientTypes.RouteVehicleTravelStep(distance: 1, duration: 2, instruction: "continue", type: .continue)
        let step2 = GeoRoutesClientTypes.RouteVehicleTravelStep(distance: 2, duration: 5, instruction: "continue", type: .continue)
        let legDetails = GeoRoutesClientTypes.RouteVehicleLegDetails(travelSteps: [step1, step2])
        let routeLegDetails = GeoRoutesClientTypes.RouteLeg(vehicleLegDetails: legDetails)
        let route = GeoRoutesClientTypes.Route(legs: [routeLegDetails])
        
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), route: route, firstDestination: firstDestination, secondDestination: secondDestination)
        
        XCTAssertEqual(navigationVCViewModel.getData().count, 0, "Expected get data count")
    }
    
    func testGetItemCountWithZeroSteps() throws {
        let legDetails = GeoRoutesClientTypes.RouteVehicleLegDetails(travelSteps: [])
        let routeLegDetails = GeoRoutesClientTypes.RouteLeg(vehicleLegDetails: legDetails)
        let route = GeoRoutesClientTypes.Route(legs: [routeLegDetails])
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), route: route, firstDestination: firstDestination, secondDestination: secondDestination)
        
        XCTAssertEqual(navigationVCViewModel.getItemCount(), 0, "Expected get item count")
    }
    
    func testGetItemCountWithValidSteps() throws {
        let step1 = GeoRoutesClientTypes.RouteVehicleTravelStep(distance: 1, duration: 2, instruction: "continue", type: .continue)
        let step2 = GeoRoutesClientTypes.RouteVehicleTravelStep(distance: 2, duration: 5, instruction: "continue", type: .continue)
        let legDetails = GeoRoutesClientTypes.RouteVehicleLegDetails(travelSteps: [step1, step2])
        let routeLegDetails = GeoRoutesClientTypes.RouteLeg(vehicleLegDetails: legDetails)
        let route = GeoRoutesClientTypes.Route(legs: [routeLegDetails])
        
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), route: route, firstDestination: firstDestination, secondDestination: secondDestination)
        XCTAssertEqual(navigationVCViewModel.getItemCount(), 0, "Expected get item count")
    }
    
}
