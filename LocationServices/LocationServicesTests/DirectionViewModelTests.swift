//
//  DirectionViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class DirectionViewModelTests: XCTestCase {
    
    var routingService: RoutingAPIServiceMock!
    var locationService: LocationAPIServiceMock!
    var directionViewModel: DirectionViewModel!
    var delegate: MockDirectionViewModelOutputDelegate!
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
        
        userLocation = (lat: 40.7487776237092, long: -73.98554260340953)
        routingService = RoutingAPIServiceMock(delay: Constants.apiRequestDuration)
        locationService = LocationAPIServiceMock(delay: Constants.apiRequestDuration)
        directionViewModel = DirectionViewModel(service: locationService, routingService: routingService)
        delegate = MockDirectionViewModelOutputDelegate()
        directionViewModel.delegate = delegate
        search = SearchPresentation(placeId: "myLocation",
                                       fullLocationAddress: "Times Square, New York",
                                       distance: nil,
                                       countryName: nil,
                                       cityName: nil,
                                       placeLat: userLocation?.lat,
                                       placeLong: userLocation?.long,
                                       name: "Times Square")
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
        XCTAssertEqual(self.delegate.isMyLocationAlreadySelect, true, "Expected isMyLocationAlreadySelected true")
    }
    
    func testMyLocationSelected() throws {
        directionViewModel.userLocation = userLocation
        
        directionViewModel.myLocationSelected()
        XCTAssertEqual(directionViewModel.getSearchCellModel().first?.placeId, nil, "Expected location nil ")
    }
    
    func testSearchWithSuggesstionWithTextMyLocation() throws {
        locationService.putSearchTextResult = [search]
        directionViewModel.searchWithSuggesstion(text: "Times Square", userLat: userLocation.lat, userLong: userLocation.long)
        
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }

    func testSearchWithSuggesstionWithTextFailure() throws {
        directionViewModel.searchWithSuggesstion(text: "Times Square", userLat: userLocation.lat, userLong: userLocation.long)
        
        XCTWaiter().wait(until: {
            return !self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult false")
    }
    
    func testSearchWithText() throws {
        locationService.putSearchTextResult = [search]
        directionViewModel.searchWith(text: "Times Square", userLat: userLocation.lat, userLong: userLocation.long)
        
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }

    func testSearchWithTextFailure() throws {
        directionViewModel.searchWith(text: "Times Square", userLat: userLocation.lat, userLong: userLocation.long)
        
        XCTWaiter().wait(until: {
            return !self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
    
    func testNumberOfRowsInSection() throws {
        locationService.putSearchTextResult = [search]
        directionViewModel.searchWithSuggesstion(text: "Times Square", userLat: userLocation.lat, userLong: userLocation.long)
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
        XCTAssertEqual(directionViewModel.numberOfRowsInSection(), 1, "Expecting number of rows in section")
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
        locationService.putSearchWithPositionResult = .success([search])
        directionViewModel.searchWith(text: "40.7487776237092, -73.98554260340953", userLat: nil, userLong: nil)
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
    
    func testSearchSelectedPlaceWithMyLocation() throws {
        locationService.putSearchWithPositionResult = .success([search])
        directionViewModel.searchWith(text: "40.7487776237092, -73.98554260340953", userLat: userLocation.lat, userLong: userLocation.long)
        
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
}

class MockDirectionViewModelOutputDelegate : DirectionViewModelOutputDelegate {
    var hasSearchResult = false
    var hasGetLocalRouteOptions = false
    var hasReloadView = false
    var hasSelectedPlaceResult = false
    var hasAlertShown = false
    var isMyLocationAlreadySelect = false
    
    func searchResult(mapModel: [LocationServices.MapModel]) {
        hasSearchResult = true
    }
    
    func reloadView() {
        hasReloadView = true
    }
    
    func selectedPlaceResult(mapModel: [LocationServices.MapModel]) {
        hasSelectedPlaceResult = true
    }
    
    func isMyLocationAlreadySelected() -> Bool {
        isMyLocationAlreadySelect = true
        return isMyLocationAlreadySelect
    }
    
    func getLocalRouteOptions(tollOption: Bool, ferriesOption: Bool) {
        hasGetLocalRouteOptions = true
    }
    
    func showAlert(_ model: LocationServices.AlertModel) {
        self.hasAlertShown = true
    }
    
}
