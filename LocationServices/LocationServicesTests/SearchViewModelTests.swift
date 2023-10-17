//
//  SearchViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices
import CoreLocation

final class SearchViewModelTests: XCTestCase {

    var userLocation: CLLocationCoordinate2D!
    var searchViewModel: SearchViewModel!
    var locationService: LocationAPIServiceMock!
    var delegate: MockSearchViewModelOutputDelegate!
    var search: SearchPresentation!
    enum Constants {
        static let waitRequestDuration: TimeInterval = 10
        static let apiRequestDuration: TimeInterval = 1
        static let defaultError = NSError(domain: "Search error", code: -1)
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        userLocation  = CLLocationCoordinate2D(latitude: 40.75790965683081, longitude: -73.98559624758715)
        
        locationService = LocationAPIServiceMock(delay: Constants.apiRequestDuration)
        searchViewModel = SearchViewModel(service: locationService)
        delegate = MockSearchViewModelOutputDelegate()
        searchViewModel.delegate = delegate
        search = SearchPresentation(placeId: "myLocation",
                                       fullLocationAddress: "Times Square, New York",
                                       distance: nil,
                                       countryName: nil,
                                       cityName: nil,
                                       placeLat: userLocation?.latitude,
                                       placeLong: userLocation?.longitude,
                                       name: "Times Square")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSearchWithSuggesstionWithCoordinatesFailure() throws {
        locationService.putSearchWithPositionResult = .failure(Constants.defaultError)
        
        searchViewModel.searchWithSuggesstion(text: "40.75790965683081, -73.98559624758715", userLat: userLocation.latitude, userLong: userLocation.longitude)
        
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasAlertShown ?? false
        }, timeout: Constants.waitRequestDuration, message: "Error alert should've been displayed")
    }
    
    func testSearchWithSuggesstionWithCoordinatesSuccess() throws {
        locationService.putSearchWithPositionResult = .success([search])
        searchViewModel.searchWithSuggesstion(text: "40.75790965683081, -73.98559624758715", userLat: userLocation.latitude, userLong: userLocation.longitude)
        
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
    
    func testSearchWithSuggesstionWithTextSuccess() throws {
        locationService.putSearchTextResult = [search]
        searchViewModel.searchWithSuggesstion(text: "Times Square", userLat: userLocation.latitude, userLong: userLocation.longitude)
        
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
    
    func testSearchWithText() throws {
        locationService.putSearchTextResult = [search]
        searchViewModel.searchWith(text: "Times Square", userLat: userLocation.latitude, userLong: userLocation.longitude)
        
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
    
    func testSearchWithCoordinates() throws {
        locationService.putSearchWithPositionResult = .success([search])
        searchViewModel.searchWith(text: "40.75790965683081, -73.98559624758715", userLat: userLocation.latitude, userLong: userLocation.longitude)
        
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
    
    func testSearchWithEmptyText() throws {
        locationService.putSearchTextResult = [search]
        searchViewModel.searchWith(text: "", userLat: userLocation.latitude, userLong: userLocation.longitude)
        
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
    
    func testSearchWithFailure() throws {
        locationService.putSearchTextResult = []
        searchViewModel.searchWith(text: "AS", userLat: userLocation.latitude, userLong: userLocation.longitude)
        
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }

    func testNumberOfRowsInSection() throws {
        locationService.putSearchTextResult = [search]
        searchViewModel.searchWithSuggesstion(text: "Times Square", userLat: userLocation.latitude, userLong: userLocation.longitude)
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
        XCTAssertEqual(searchViewModel.numberOfRowsInSection(), 1, "Expecting number of rows in section")
    }
    
    func testGetSearchCellModelWithEmptyResults() throws {
        XCTAssertEqual(searchViewModel.getSearchCellModel().count, 0, "Expecting 0 records")
    }
    
    func testGetSearchCellModelWithResults() throws {
        locationService.putSearchTextResult = [search]
        searchViewModel.searchWithSuggesstion(text: "Times Square", userLat: userLocation.latitude, userLong: userLocation.longitude)
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
        XCTAssertEqual(searchViewModel.getSearchCellModel().first?.locationName, search.name, "Expecting location name")
    }

    func testSearchSelectedPlaceWithPlaceId() throws {
        locationService.putSearchTextResult = [search]
        searchViewModel.searchWithSuggesstion(text: "Times Square", userLat: userLocation.latitude, userLong: userLocation.longitude)
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
        let indexPath = IndexPath(row: 0, section: 0)
        _ = searchViewModel.getSearchCellModel()
        XCTAssertEqual(searchViewModel.searchSelectedPlaceWith(indexPath, lat: userLocation.latitude, long: userLocation.longitude), true, "Expecting true")
    }
    
    func testSearchSelectedPlaceWithLocation() throws {
        search = SearchPresentation(placeId: nil,
                                       fullLocationAddress: "My Location",
                                       distance: nil,
                                       countryName: nil,
                                       cityName: nil,
                                       placeLat: userLocation?.latitude,
                                       placeLong: userLocation?.longitude,
                                       name: nil)
        locationService.putSearchTextResult = [search]
        searchViewModel.searchWithSuggesstion(text: "Times Square", userLat: userLocation.latitude, userLong: userLocation.longitude)
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
        let indexPath = IndexPath(row: 0, section: 0)
        _ = searchViewModel.getSearchCellModel()
        XCTAssertEqual(searchViewModel.searchSelectedPlaceWith(indexPath, lat: userLocation.latitude, long: userLocation.longitude), true, "Expecting true")
    }
    
    func testSearchSelectedPlaceWithLocationName() throws {
        locationService.putSearchTextResult = [search]
        search = SearchPresentation(placeId: nil,
                                       fullLocationAddress: "My Location",
                                       distance: nil,
                                       countryName: nil,
                                       cityName: nil,
                                       placeLat: nil,
                                       placeLong: nil,
                                       name: "Times Square")
        locationService.putSearchTextResult = [search]
        searchViewModel.searchWithSuggesstion(text: "Times Square", userLat: userLocation.latitude, userLong: userLocation.longitude)
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
        let indexPath = IndexPath(row: 0, section: 0)
        _ = searchViewModel.getSearchCellModel()
        XCTAssertEqual(searchViewModel.searchSelectedPlaceWith(indexPath, lat: userLocation.latitude, long: userLocation.longitude), false, "Expecting false")
        XCTWaiter().wait(until: {
            return self.delegate.hasSearchResult
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
    
}


class MockSearchViewModelOutputDelegate: SearchViewModelOutputDelegate {
    var hasSearchResult = false
    var hasSelectedPlaceResult = false
    var hasAlertShown = false
    
    func searchResult(mapModel: [LocationServices.MapModel], shouldDismiss: Bool, showOnMap: Bool) {
        hasSearchResult = true
    }
    
    func selectedPlaceResult(mapModel: LocationServices.MapModel) {
        hasSelectedPlaceResult = true
    }
    
    func showAlert(_ model: LocationServices.AlertModel) {
        hasAlertShown = true
    }
    
    
}
