//
//  DirectionViewModelTests.swift
//  DirectionViewModelTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class DirectionViewModelTests: XCTestCase {
    
    let directionViewModel = DirectionViewModel(service: LocationService(), routingService: RoutingAPIService())
    let directionVC = DirectionVC()
    let userLocation = (lat: 40.7487776237092, long: -73.98554260340953)
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        directionViewModel.delegate = directionVC
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLoadLocalOptionsWithEmptyStorage() throws {
        directionViewModel.loadLocalOptions()
        XCTAssertEqual(directionViewModel.avoidTolls, false, "Expected avoidTolls false")
    }
    
    func testLoadLocalOptionsWithFilledStorage() throws {
        UserDefaultsHelper.save(value: true, key: .tollOptions)
        UserDefaultsHelper.save(value: true, key: .ferriesOptions)
        
        directionViewModel.loadLocalOptions()
        XCTAssertEqual(directionViewModel.avoidTolls, true, "Expected avoidTolls true")
    }
    
    func testAddMyLocationItemNoLocationSelected() throws {
        directionViewModel.addMyLocationItem()
        XCTAssertEqual(directionViewModel.getSearchCellModel().first?.placeId, nil, "Expected my location no nil")
    }
    
    func testAddMyLocationItemLocationSelected() throws {
        directionViewModel.userLocation = userLocation
                
        directionViewModel.addMyLocationItem()
        XCTAssertEqual(directionViewModel.getSearchCellModel().first?.placeId, "myLocation", "Expected my location no nil")
    }
    
    func testAddMyLocationItemNoCurrentLocation() throws {
                
        directionViewModel.addMyLocationItem()
        XCTAssertEqual(directionViewModel.getSearchCellModel().first?.placeId, nil, "Expected my location no nil")
    }
    
    func testMyLocationSelected() throws {
        directionViewModel.userLocation = userLocation
        
        directionViewModel.myLocationSelected()
        XCTAssertEqual(directionViewModel.getSearchCellModel().first?.placeId, nil, "Expected location nil ")
    }
    
    func testSearchWithSuggesstionWithTextMyLocation() throws {
        directionViewModel.searchWithSuggesstion(text: "40.7487776237092, -73.98554260340953", userLat: userLocation.lat, userLong: userLocation.long)
        sleep(3)
        XCTAssertEqual(directionViewModel.getSearchCellModel().first?.locationName, "James Lawrence Thomas", "Expected location name")
    }

    func testSearchWithSuggesstionWithTextFailure() throws {
        directionViewModel.searchWithSuggesstion(text: "Tdfimes Squadfdfsre", userLat: userLocation.lat, userLong: userLocation.long)
        sleep(3)
        XCTAssertEqual(directionViewModel.getSearchCellModel().first?.locationName, nil, "Expected location nil")
    }
    
    func testSearchWithText() throws {
        directionViewModel.searchWith(text: "40.7487776237092, -73.98554260340953", userLat: userLocation.lat, userLong: userLocation.long)
        sleep(3)
        XCTAssertEqual(directionViewModel.getSearchCellModel().first?.locationName, "James Lawrence Thomas", "Expected location name")
    }

    func testSearchWithTextFailure() throws {
        directionViewModel.searchWith(text: "Tdfimes Squadfdfsre", userLat: userLocation.lat, userLong: userLocation.long)
        sleep(3)
        XCTAssertEqual(directionViewModel.getSearchCellModel().first?.locationName, nil, "Expected location nil")
    }
    
    func testNumberOfRowsInSection() throws {
        directionViewModel.searchWith(text: "40.7487776237092, -73.98554260340953", userLat: userLocation.lat, userLong: userLocation.long)
        sleep(5)
        XCTAssertEqual(directionViewModel.numberOfRowsInSection(), 1, "Expected number of rows")
    }
    
    func testGetMyLocationItem() throws {
        XCTAssertEqual(directionViewModel.getMyLocationItem().placeId, "myLocation", "Expected location nil")
    }
    
    func testGetSearchCellModelWithEmptyResults() throws {
        directionViewModel.searchWith(text: "Tdfimes Squadfdfsre", userLat: userLocation.lat, userLong: userLocation.long)
        sleep(5)
        XCTAssertEqual(directionViewModel.getSearchCellModel().first?.locationName, nil, "Expected nil location in getSearchCellModel")
    }
    
    func testGetSearchCellModelWithResults() throws {
        directionViewModel.searchWith(text: "40.7487776237092, -73.98554260340953", userLat: userLocation.lat, userLong: userLocation.long)
        sleep(5)
        XCTAssertEqual(directionViewModel.getSearchCellModel().first?.locationName, "James Lawrence Thomas", "Expected location count in getSearchCellModel")
    }
    
    func testSearchSelectedPlaceWithMyLocation() throws {
        directionViewModel.searchWith(text: "40.7487776237092, -73.98554260340953", userLat: userLocation.lat, userLong: userLocation.long)
        sleep(5)
        
        let result = directionViewModel.searchSelectedPlaceWith(directionViewModel.getSearchCellModel().first!, lat: userLocation.lat, long: userLocation.long)
        XCTAssertEqual(result, true, "Expected searchSelectedPlaceWith true")
    }
    
//    func testGetCurrentNavigationLegsWithSucceedData() throws {
//        let firstDestination = MapModel(placeName: "Times Square", placeAddress: nil, placeLat: 40.75804781268635, placeLong: -73.98554260340953)
//
//        let secondDestination = MapModel(placeName: "CUNY Graduate Center", placeAddress: nil, placeLat: 40.7487776237092, placeLong: -73.98404872540857)
//        directionViewModel.userLocation = userLocation
//
//        directionViewModel.addMyLocationItem()
//
//        directionViewModel.calculateRouteWith(destinationPosition: firstDestination, departurePosition: secondDestination){ data,model  in
//
//        }
//        sleep(5)
//        let result = directionViewModel.searchSelectedPlaceWith(directionViewModel.getSearchCellModel().first!, lat: userLocation.lat, long: userLocation.long)
//        sleep(5)
//        directionVC.calculateRoute()
//        sleep(5)
//        XCTAssertEqual(try directionViewModel.getCurrentNavigationLegsWith(.car).get().count, 0, "Expected")
//    }
//
//
//    func testGetSumDataWithSucceedData() {
//        directionViewModel.defaultTravelMode =
//        directionViewModel.getSumData(.car)
//    }
}
