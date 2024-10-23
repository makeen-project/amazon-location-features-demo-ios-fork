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
        let step = RouteNavigationStep(distance: 2, duration: 2, instruction: "continue", type: .continue)
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), steps: [step], summaryData: (totalDistance: 0.7, totalDuration: 15), firstDestionation: firstDestination, secondDestionation: secondDestination)
        XCTAssertEqual(navigationVCViewModel.firstDestionation?.placeName, "Times Square", "Expected Times Square place name")
    }

    func testInitWithEmptySteps() throws {
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), steps: [], summaryData: (totalDistance: 0.7, totalDuration: 15), firstDestionation: firstDestination, secondDestionation: secondDestination)
        XCTAssertEqual(navigationVCViewModel.firstDestionation?.placeName, "Times Square", "Expected Times Square place name")
    }
    
    func testInitWithStepsWithoutStreetNames() throws {
        let firstDestination = MapModel(placeName: "Times Square", placeAddress: nil, placeLat: 40.75804781268635, placeLong: -73.98554260340953)
        
        let secondDestination = MapModel(placeName: "CUNY Graduate Center", placeAddress: nil, placeLat: 40.7487776237092, placeLong: -73.98404872540857)
        
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), steps: [], summaryData: (totalDistance: 0.7, totalDuration: 15), firstDestionation: firstDestination, secondDestionation: secondDestination)
        XCTAssertEqual(navigationVCViewModel.firstDestionation?.placeName, "Times Square", "Expected Times Square place name")
    }
    
    func testUpdateWithValidData() throws {
        
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), steps: [], summaryData: (totalDistance: 0.7, totalDuration: 15), firstDestionation: firstDestination, secondDestionation: secondDestination)

        let step = RouteNavigationStep(distance: 2, duration: 2, instruction: "continue", type: .continue)
        
        navigationVCViewModel.update(steps: [step], summaryData: (totalDistance: 0.7, totalDuration: 20))
        
        XCTAssertEqual(navigationVCViewModel.steps[0].duration, 2, "Expected steps duration 2")
    }
    
    func testGetSummaryData() throws {
        
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), steps: [], summaryData: (totalDistance: 0.7, totalDuration: 15), firstDestionation: firstDestination, secondDestionation: secondDestination)
        
        let step = RouteNavigationStep(distance: 2, duration: 2, instruction: "continue", type: .continue)
        
        navigationVCViewModel.update(steps: [step], summaryData: (totalDistance: 0.7, totalDuration: 20))
        
        XCTAssertEqual(navigationVCViewModel.getSummaryData().totalDistance, "1 m", "Expected summary total distance 1 m")
    }
    
    func testGetDataWithZeroSteps() throws {
        
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), steps: [], summaryData: (totalDistance: 0.7, totalDuration: 15), firstDestionation: firstDestination, secondDestionation: secondDestination)
        
        XCTAssertEqual(navigationVCViewModel.getData().count, 0, "Expected get data count")
    }
    
    func testGetDataWithOneStep() throws {
        
        let step = RouteNavigationStep(distance: 0.01, duration: 2, instruction: "continue", type: .continue)
        
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), steps: [step], summaryData: (totalDistance: 0.7, totalDuration: 15), firstDestionation: firstDestination, secondDestionation: secondDestination)
        
        XCTAssertEqual(navigationVCViewModel.getData().count, 0, "Expected get data count")
    }
    
    
    func testGetDataWithMultipleSteps() throws {
        
        let step1 = RouteNavigationStep(distance: 0.01, duration: 2, instruction: "continue", type: .continue)
        
        let step2 = RouteNavigationStep(distance: 0.02, duration: 5, instruction: "continue", type: .continue)
        
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), steps: [step1, step2], summaryData: (totalDistance: 0.7, totalDuration: 15), firstDestionation: firstDestination, secondDestionation: secondDestination)
        
        XCTAssertEqual(navigationVCViewModel.getData().count, 0, "Expected get data count")
    }
    
    func testGetItemCountWithZeroSteps() throws {
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), steps: [], summaryData: (totalDistance: 0.7, totalDuration: 15), firstDestionation: firstDestination, secondDestionation: secondDestination)
        
        XCTAssertEqual(navigationVCViewModel.getItemCount(), 0, "Expected get item count")
    }
    
    func testGetItemCountWithValidSteps() throws {
        
        let step1 = RouteNavigationStep(distance: 0.01, duration: 2, instruction: "continue", type: .continue)
        
        let step2 = RouteNavigationStep(distance: 0.02, duration: 5, instruction: "continue", type: .continue)
        
        let navigationVCViewModel = NavigationVCViewModel(service: LocationService(), steps: [step1, step2], summaryData: (totalDistance: 0.7, totalDuration: 15), firstDestionation: firstDestination, secondDestionation: secondDestination)
        XCTAssertEqual(navigationVCViewModel.getItemCount(), 0, "Expected get item count")
    }
    
}
