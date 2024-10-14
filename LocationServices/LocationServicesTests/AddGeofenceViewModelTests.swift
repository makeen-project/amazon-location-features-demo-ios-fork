//
//  AddGeofenceViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class AddGeofenceViewModelTests: XCTestCase {
    
    enum Constants {
        static let apiRequestDuration: TimeInterval = 1
        static let waitRequestDuration: TimeInterval = 10
        
        static let geofenceId = "TestGeofence"
        static let geofenceLat: TimeInterval = 10
        static let geofenceLong: TimeInterval = 15
        static let geofenceRadius: Double = 20
        
        static let updatedGeofenceLat: TimeInterval = 15
        static let updatedGeofenceLong: TimeInterval = 10
        static let updatedGeofenceRadius: Double = 25
        
        static var testGeofenceModel: GeofenceDataModel {
            return GeofenceDataModel(id: geofenceId, lat: geofenceLat, long: geofenceLong, radius: Double(geofenceRadius))
        }
        static let defaultError = NSError(domain: "Geofence error", code: -1)
    }
    
    var viewModel: AddGeofenceViewModel!
    var geofenceService: GeofenceAPIServiceMock!
    var locationService: LocationAPIServiceMock!
    var viewModelDelegate: AddGeofenceViewModelOutputProtocolMock!
    var userLocation: (lat: Double, long: Double)!
    var search: SearchPresentation!
    
    override func setUpWithError() throws {
        userLocation = (lat: 40.7487776237092, long: -73.98554260340953)
        search = SearchPresentation(placeId: "myLocation",
                                       fullLocationAddress: "Times Square, New York",
                                       distance: nil,
                                       countryName: nil,
                                       cityName: nil,
                                       placeLat: userLocation?.lat,
                                       placeLong: userLocation?.long,
                                       name: "Times Square")
        geofenceService = GeofenceAPIServiceMock(delay: Constants.apiRequestDuration)
        locationService = LocationAPIServiceMock(delay: Constants.apiRequestDuration)
        viewModelDelegate = AddGeofenceViewModelOutputProtocolMock()
        setupViewModel(with: [])
    }
    
    override func tearDownWithError() throws {
        geofenceService = nil
        locationService = nil
        viewModel = nil
        viewModelDelegate = nil
    }
    
    private func setupViewModel(with list: [GeofenceDataModel]) {
        viewModel = AddGeofenceViewModel(searchService: locationService, geofenceService: geofenceService, activeGeofencesLists: list)
        viewModel.delegate = viewModelDelegate
    }
    
    func testIsGeofenceNameValidWithValidName() throws {
        let geofenceName = "TestGeofence"
        XCTAssertTrue(viewModel.isGeofenceNameValid(geofenceName), "Expected true for valid geofence name.")
    }
    
    func testIsGeofenceNameValidWithTooLongName() throws {
        let geofenceName = "TestGeofenceTestGeofence"
        XCTAssertFalse(viewModel.isGeofenceNameValid(geofenceName), "Expected false for too long geofence name.")
    }
    
    func testIsGeofenceNameValidWithNumberAtStart() throws {
        let geofenceName = "1TestGeofence"
        XCTAssertFalse(viewModel.isGeofenceNameValid(geofenceName), "Expected false for geofence name start not with letter.")
    }
    
    func testIsGeofenceNameValidWithSpecialCharacter() throws {
        let geofenceName = "Test.Geofence"
        XCTAssertFalse(viewModel.isGeofenceNameValid(geofenceName), "Expected false for geofence name contain special character.")
    }
    
    func testIsGeofenceModelValidWithValidModel() throws {
        let geofenceModel = GeofenceDataModel(id: "TestGeofence", lat: 0, long: 0, radius: 0)
        XCTAssertTrue(viewModel.isGeofenceModelValid(geofenceModel), "Expected true for valid geofence model.")
    }
    
    func testIsGeofenceModelValidWithInvalidName() throws {
        let geofenceModel = GeofenceDataModel(id: "Test Geofence", lat: 0, long: 0, radius: 0)
        XCTAssertFalse(viewModel.isGeofenceModelValid(geofenceModel), "Expected false for invalid name.")
    }
    
    func testIsGeofenceModelValidWithInvalidLocation() throws {
        let geofenceModel = GeofenceDataModel(id: "TestGeofence", lat: nil, long: nil, radius: 0)
        XCTAssertFalse(viewModel.isGeofenceModelValid(geofenceModel), "Expected false for invalid location.")
    }
    
    func testIsGeofenceModelValidWithInvalidRadius() throws {
        let geofenceModel = GeofenceDataModel(id: "TestGeofence", lat: 0, long: 0, radius: nil)
        XCTAssertFalse(viewModel.isGeofenceModelValid(geofenceModel), "Expected false for invalid radius.")
    }
    
    func testDeleteDataWithoutID() throws {
        let geofenceModel = GeofenceDataModel(id: nil, lat: 0, long: 0, radius: 0)
        viewModel.deleteData(with: geofenceModel)
        
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, StringConstant.geofenceNoIdentifier)
        XCTAssertNil(viewModelDelegate.alertMock.alertModel?.okHandler)
    }
    
    func testDeleteDataDeclined() throws {
        let defaultGeofenceList = [Constants.testGeofenceModel]
        setupViewModel(with: defaultGeofenceList)
        
        viewModel.deleteData(with: Constants.testGeofenceModel)
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, StringConstant.deleteGeofenceAlertMessage)
        XCTAssertNotNil(viewModelDelegate.alertMock.alertModel?.okHandler)
        XCTAssertEqual(viewModel.activeGeofencesLists.count, defaultGeofenceList.count)
        XCTAssertEqual(viewModel.activeGeofencesLists.first?.id, Constants.geofenceId)
    }
    
    func testDeleteDataAcceptedSuccess() throws {
        let defaultGeofenceList = [Constants.testGeofenceModel]
        setupViewModel(with: defaultGeofenceList)
        
        viewModel.deleteData(with: Constants.testGeofenceModel)
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, StringConstant.deleteGeofenceAlertMessage)
        XCTAssertNotNil(viewModelDelegate.alertMock.alertModel?.okHandler)
        
        geofenceService.mockDeleteGeofenceResult = .success(Constants.geofenceId)
        viewModelDelegate.alertMock.tapMainActionButton()
        
        XCTWaiter().wait(until: { [weak self] in
            return self?.viewModelDelegate.finishProcessCalled ?? false
        }, timeout: Constants.waitRequestDuration, message: "Delete geofence result should've been received")
        XCTAssertTrue(viewModel.activeGeofencesLists.isEmpty)
    }
    
    func testDeleteDataAcceptedFailure() throws {
        let defaultGeofenceList = [Constants.testGeofenceModel]
        setupViewModel(with: defaultGeofenceList)
        
        viewModel.deleteData(with: Constants.testGeofenceModel)
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, StringConstant.deleteGeofenceAlertMessage)
        XCTAssertNotNil(viewModelDelegate.alertMock.alertModel?.okHandler)
        
        geofenceService.mockDeleteGeofenceResult = .failure(Constants.defaultError)
        viewModelDelegate.alertMock.tapMainActionButton()
        
        XCTWaiter().wait(until: { [weak self] in
            return self?.viewModelDelegate.alertMock.showAlertCalled ?? false
        }, timeout: Constants.waitRequestDuration, message: "Error alert should've been displayed")
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, Constants.defaultError.localizedDescription)
    }
    
    func testSaveDataNewSucceed() async throws {
        geofenceService.mockPutGeofenceResult = .success(Constants.testGeofenceModel)
        let result = try await viewModel.saveData(with: Constants.geofenceId, lat: Constants.geofenceLat, long: Constants.geofenceLong, radius: Constants.geofenceRadius)

        switch result {
            case .success(let geofenceModel):
                XCTAssertEqual(viewModel.activeGeofencesLists.count, 1)
                let firstModel = try XCTUnwrap(viewModel.activeGeofencesLists.first)
                [firstModel, geofenceModel].forEach { model in
                    XCTAssertEqual(model.id, Constants.testGeofenceModel.id)
                    XCTAssertEqual(model.lat, Constants.testGeofenceModel.lat)
                    XCTAssertEqual(model.long, Constants.testGeofenceModel.long)
                    XCTAssertEqual(model.radius, Constants.testGeofenceModel.radius)
                }
            case .failure:
                XCTFail("Result should be success")
        }
    }
    
    func testSaveDataNewFailure() async throws {
        geofenceService.mockPutGeofenceResult = .failure(Constants.defaultError)
        let result = try await viewModel.saveData(with: Constants.geofenceId, lat: Constants.geofenceLat, long: Constants.geofenceLong, radius: Constants.geofenceRadius)
        switch result {
        case .success:
            XCTFail("Result should be failure")
        case .failure(let error):
            XCTAssertEqual(error as NSError, Constants.defaultError)
            XCTAssertEqual(viewModel.activeGeofencesLists.count, 0)
        }
    }
    
    func testSaveDataOldSucceed() async throws {
        let defaultGeofenceList = [Constants.testGeofenceModel]
        setupViewModel(with: defaultGeofenceList)
        
        let updatedGeofence = GeofenceDataModel(id: Constants.geofenceId, lat: Constants.updatedGeofenceLat, long: Constants.updatedGeofenceLong, radius: Constants.updatedGeofenceRadius)
        geofenceService.mockPutGeofenceResult = .success(updatedGeofence)

        let result = try await viewModel.saveData(with: Constants.geofenceId, lat: Constants.updatedGeofenceLat, long: Constants.updatedGeofenceLong, radius: Constants.updatedGeofenceRadius)
        
        switch result {
        case .success(let geofenceModel):
            XCTAssertEqual(viewModel.activeGeofencesLists.count, 1)
            _ = try XCTUnwrap(viewModel.activeGeofencesLists.first)
            XCTAssertEqual(geofenceModel.id, Constants.testGeofenceModel.id)
            XCTAssertEqual(geofenceModel.lat, Constants.updatedGeofenceLat)
            XCTAssertEqual(geofenceModel.long, Constants.updatedGeofenceLong)
            XCTAssertEqual(geofenceModel.radius, Constants.updatedGeofenceRadius)
        case .failure:
            XCTFail("Result should be success")
        }
    }
    
    func testSaveDataOldFailure() async throws {
        let defaultGeofenceList = [Constants.testGeofenceModel]
        setupViewModel(with: defaultGeofenceList)
        
        geofenceService.mockPutGeofenceResult = .failure(Constants.defaultError)
        let result = try await viewModel.saveData(with: Constants.geofenceId, lat: Constants.updatedGeofenceLat, long: Constants.updatedGeofenceLong, radius: Constants.updatedGeofenceRadius)
        switch result {
        case .success:
            XCTFail("Result should be failure")
        case .failure(let error):
            XCTAssertEqual(error as NSError, Constants.defaultError)
            XCTAssertEqual(viewModel.activeGeofencesLists.count, 1)
        }
    }
    
    func testSearchWithSuggestionWithEmptyText() async throws {
        setupViewModel(with: [Constants.testGeofenceModel])
        locationService.mockSearchTextWithSuggestionResult = .success([search])
        _ = try await viewModel.searchWithSuggestion(text: "", userLat: userLocation.lat, userLong: userLocation.long)
        XCTWaiter().wait(until: {
            return self.viewModelDelegate.searchResultCalled
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult false")
    }
    
    func testSearchWithSuggestion() async throws {
        setupViewModel(with: [Constants.testGeofenceModel])
        locationService.mockSearchTextWithSuggestionResult = .success([search])
        _ = try await viewModel.searchWithSuggestion(text: "Times Square", userLat: userLocation.lat, userLong: userLocation.long)
        XCTWaiter().wait(until: {
            return self.viewModelDelegate.searchResultCalled
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
    
    func testSearchWithSuggestionWithCoordinates() async throws {
        setupViewModel(with: [Constants.testGeofenceModel])
        locationService.mockSearchTextWithSuggestionResult = .success([search])
        _ = try await viewModel.searchWithSuggestion(text: "40.7487776237092, -73.98554260340953", userLat: userLocation.lat, userLong: userLocation.long)
        XCTWaiter().wait(until: {
            return self.viewModelDelegate.searchResultCalled
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
    
    func testSearchWith() async throws {
        setupViewModel(with: [Constants.testGeofenceModel])
        locationService.mockSearchTextResult = .success([search])
        _ = try await viewModel.searchWith(text: "Times Square", userLat: userLocation.lat, userLong: userLocation.long)
        XCTWaiter().wait(until: {
            return self.viewModelDelegate.searchResultCalled
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
        XCTAssertEqual(viewModel.numberOfRowsInSection(), 1, "Expecting number of rows in section")
    }
    
    func testSearchWithEmptyText() async throws {
        setupViewModel(with: [Constants.testGeofenceModel])
        locationService.mockSearchTextResult = .success([search])
        _ = try await viewModel.searchWith(text: "", userLat: userLocation.lat, userLong: userLocation.long)
        XCTWaiter().wait(until: {
            return self.viewModelDelegate.searchResultCalled
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
    }
    
    func testSearchWithCoordinates() async throws {
        setupViewModel(with: [Constants.testGeofenceModel])
        locationService.mockSearchWithPositionResult = .success([search])
        _ = try await viewModel.searchWith(text: "40.7487776237092, -73.98554260340953", userLat: userLocation.lat, userLong: userLocation.long)
        XCTWaiter().wait(until: {
            return self.viewModelDelegate.searchResultCalled
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
        XCTAssertEqual(viewModel.numberOfRowsInSection(), 1, "Expecting number of rows in section")
    }
    
    func testGetSearchCellModelWithResults() async throws {
        setupViewModel(with: [Constants.testGeofenceModel])
        locationService.mockSearchTextWithSuggestionResult = .success([search])
        _ = try await viewModel.searchWithSuggestion(text: "Times Square", userLat: userLocation.lat, userLong: userLocation.long)
        XCTWaiter().wait(until: {
            return self.viewModelDelegate.searchResultCalled
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
        XCTAssertEqual(viewModel.getSearchCellModel().isEmpty, false, "Expected false" )
    }
    
    func testNumberOfRowsInSection() async throws {
        setupViewModel(with: [Constants.testGeofenceModel])
        locationService.mockSearchTextWithSuggestionResult = .success([search])
        _ = try await viewModel.searchWithSuggestion(text: "Times Square", userLat: userLocation.lat, userLong: userLocation.long)
        XCTWaiter().wait(until: {
            return self.viewModelDelegate.searchResultCalled
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
        XCTAssertEqual(viewModel.numberOfRowsInSection(), 1, "Expecting number of rows in section")
    }
    
    func testSearchSelectedPlaceWith() async throws {
        setupViewModel(with: [Constants.testGeofenceModel])
        locationService.mockSearchTextResult = .success([search])
        locationService.mockSearchTextWithSuggestionResult = .success([search])
        locationService.mockGetPlaceResult = .success(search)
        _ = try await viewModel.searchWithSuggestion(text: "Times Square", userLat: userLocation.lat, userLong: userLocation.long)
        XCTWaiter().wait(until: {
            return self.viewModelDelegate.searchResultCalled
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
        XCTAssertEqual(viewModel.getSearchCellModel().isEmpty, false, "Expected false" )
        _ = try await viewModel.searchSelectedPlaceWith(IndexPath.init(row: 0, section: 0), lat: userLocation.lat, long: userLocation.long)
        XCTWaiter().wait(until: {
            return self.viewModelDelegate.selectedPlaceResultCalled
        }, timeout: Constants.waitRequestDuration, message: "Expected selectedPlaceResultCalled true")
    }
    
    func testSearchSelectedPlaceWithEmptyPlaceID() async throws {
        let model = GeofenceDataModel(id: nil, lat: Constants.geofenceLat, long: Constants.geofenceLong, radius: Constants.geofenceRadius)
        let search = SearchPresentation(placeId: nil,
                                        fullLocationAddress: "Times Square, New York",
                                        distance: nil,
                                        countryName: nil,
                                        cityName: nil,
                                        placeLat: userLocation?.lat,
                                        placeLong: userLocation?.long,
                                        name: "Times Square")
        setupViewModel(with: [model])
        locationService.mockSearchTextWithSuggestionResult = .success([search])
        locationService.mockGetPlaceResult = .success(search)
        _ = try await viewModel.searchWithSuggestion(text: "Times Square", userLat: userLocation.lat, userLong: userLocation.long)
        XCTWaiter().wait(until: {
            return self.viewModelDelegate.searchResultCalled
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
        XCTAssertEqual(viewModel.getSearchCellModel().isEmpty, false, "Expected false" )
        _ = try await viewModel.searchSelectedPlaceWith(IndexPath.init(row: 0, section: 0), lat: userLocation.lat, long: userLocation.long)
        XCTWaiter().wait(until: {
            return self.viewModelDelegate.selectedPlaceResultCalled
        }, timeout: Constants.waitRequestDuration, message: "Expected selectedPlaceResultCalled true")
    }
    
    func testSearchSelectedPlaceWithEmptyLat() async throws {
        let model = GeofenceDataModel(id: nil, lat: nil, long: nil, radius: Constants.geofenceRadius)
        let search = SearchPresentation(placeId: nil,
                                        fullLocationAddress: "Times Square, New York",
                                        distance: nil,
                                        countryName: nil,
                                        cityName: nil,
                                        placeLat: nil,
                                        placeLong: nil,
                                        name: "Times Square")
        setupViewModel(with: [model])
        locationService.mockSearchTextWithSuggestionResult = .success([search])
        locationService.mockGetPlaceResult = .success(search)
        _ = try await viewModel.searchWithSuggestion(text: "Times Square", userLat: userLocation.lat, userLong: userLocation.long)
        XCTWaiter().wait(until: {
            return self.viewModelDelegate.searchResultCalled
        }, timeout: Constants.waitRequestDuration, message: "Expected hasSearchResult true")
        XCTAssertEqual(viewModel.getSearchCellModel().isEmpty, false, "Expected false" )
    }
}

