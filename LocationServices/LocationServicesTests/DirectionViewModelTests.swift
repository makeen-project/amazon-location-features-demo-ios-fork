//
//  DirectionViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices
import CoreLocation
import AWSLocationXCF

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
        XCTAssertEqual(directionViewModel.avoidTolls, true, "Expected avoidTolls false")
    }
    
    func testLoadLocalOptionsWithFilledStorage() throws {
        UserDefaultsHelper.save(value: true, key: .tollOptions)
        UserDefaultsHelper.save(value: true, key: .ferriesOptions)
        
        directionViewModel.loadLocalOptions()
        XCTAssertEqual(directionViewModel.avoidTolls, true, "Expected avoidTolls true")
    }
    
    func testAddMyLocationItemNoLocationSelected() throws {
        directionViewModel.addMyLocationItem()
        XCTAssertEqual(directionViewModel.getSearchCellModel().first?.placeId, nil, "Expected my location not nil")
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
    
    func testSearchWithSuggesstionWithCoordinates() throws {
        directionViewModel.searchWithSuggesstion(text: "40.759211, -73.984638", userLat: userLocation.lat, userLong: userLocation.long)
        
        XCTWaiter().wait(until: {
            return !self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult false")
    }
    
    func testSearchWithText() throws {
        locationService.putSearchTextResult = [search]
        directionViewModel.searchWith(text: "Times Square", userLat: userLocation.lat, userLong: userLocation.long)
        
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasSearchResult  ?? false
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
        XCTAssertEqual(directionViewModel.getSearchCellModel().isEmpty, false, "Expected false" )
    }
    
    func testSearchSelectedPlaceWithMyLocation() throws {
        locationService.putSearchWithPositionResult = .success([search])
        directionViewModel.searchWith(text: "40.7487776237092, -73.98554260340953", userLat: userLocation.lat, userLong: userLocation.long)
        
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
    
    func testGetSumData() throws {
        let sumData = directionViewModel.getSumData(.car)
        XCTAssertEqual(sumData.totalDistance, 0, "Expected 0")
    }
    
    func testSearchSelectedPlaceWith() throws {
        locationService.putSearchTextResult = [search]
        let model = SearchCellViewModel(searchType: .location, placeId: nil, locationName: "Times Square", locationDistance: 12, locationCountry: "USA", locationCity: "Manhattan", label: "Times Square", long: nil, lat: nil)
        
        let result = self.directionViewModel.searchSelectedPlaceWith(model, lat: self.userLocation.lat, long: self.userLocation.long)
        XCTAssertEqual(result, false, "Expected false")
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
 
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
    
    func testCalculateRouteWith() throws {
        let direction = DirectionPresentation(model:AWSLocationCalculateRouteResponse(), travelMode: .car)
        routingService.putResult = [AWSLocationTravelMode.car: .success(direction)]
        directionViewModel.calculateRouteWith(destinationPosition: CLLocationCoordinate2D(latitude: 40.75803155895524, longitude: -73.9855533309874) , departurePosition: CLLocationCoordinate2D(latitude: 40.75803155895524, longitude: -73.9855533309874)) { data,model  in
            XCTAssertGreaterThan(data.count, 0, "Expected atleast 1 count")
        }
    }
    
    
}

class MockDirectionViewModelOutputDelegate : DirectionViewModelOutputDelegate {
    var hasSearchResult = false
    var hasGetLocalRouteOptions = false
    var hasReloadView = false
    var hasSelectedPlaceResult = false
    var hasAlertShown = false
    var isMyLocationAlreadySelect = false
    var mapModel:[LocationServices.MapModel] = []
    
    func searchResult(mapModel: [LocationServices.MapModel]) {
        hasSearchResult = true
        self.mapModel = mapModel
    }
    
    func reloadView() {
        hasReloadView = true
    }
    
    func selectedPlaceResult(mapModel: [LocationServices.MapModel]) {
        hasSelectedPlaceResult = true
        self.mapModel = mapModel
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
