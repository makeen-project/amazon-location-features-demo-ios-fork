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
        static let waitRequestDuration: TimeInterval = 2
    }
    
    var viewModel: AddGeofenceViewModel!
    var geofenceService: GeofenceAPIServiceMock!
    var locationService: LocationAPIServiceMock!
    var viewModelDelegate: AddGeofenceViewModelOutputProtocolMock!
    
    private let testGeofenceModel = GeofenceDataModel(id: "TestGeofence", lat: 0, long: 0, radius: 0)
    private let defaultError = NSError(domain: "Geofence error", code: -1)
    
    override func setUpWithError() throws {
        geofenceService = GeofenceAPIServiceMock(delay: Constants.apiRequestDuration)
        locationService = LocationAPIServiceMock()
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
    
    func test_isGeofenceNameValid_withValidName() throws {
        let geofenceName = "TestGeofence"
        XCTAssertTrue(viewModel.isGeofenceNameValid(geofenceName), "Expected true for valid geofence name.")
    }
    
    func test_isGeofenceNameValid_withTooLongName() throws {
        let geofenceName = "TestGeofenceTestGeofence"
        XCTAssertFalse(viewModel.isGeofenceNameValid(geofenceName), "Expected false for too long geofence name.")
    }
    
    func test_isGeofenceNameValid_withNumberAtStart() throws {
        let geofenceName = "1TestGeofence"
        XCTAssertFalse(viewModel.isGeofenceNameValid(geofenceName), "Expected false for geofence name start not with letter.")
    }
    
    func test_isGeofenceNameValid_WithSpecialCharacter() throws {
        let geofenceName = "Test.Geofence"
        XCTAssertFalse(viewModel.isGeofenceNameValid(geofenceName), "Expected false for geofence name contain special character.")
    }
    
    func test_isGeofenceModelValid_withValidModel() throws {
        let geofenceModel = GeofenceDataModel(id: "TestGeofence", lat: 0, long: 0, radius: 0)
        XCTAssertTrue(viewModel.isGeofenceModelValid(geofenceModel), "Expected true for valid geofence model.")
    }
    
    func test_isGeofenceModelValid_withInvalidName() throws {
        let geofenceModel = GeofenceDataModel(id: "Test Geofence", lat: 0, long: 0, radius: 0)
        XCTAssertFalse(viewModel.isGeofenceModelValid(geofenceModel), "Expected false for invalid name.")
    }
    
    func test_isGeofenceModelValid_withInvalidLocation() throws {
        let geofenceModel = GeofenceDataModel(id: "TestGeofence", lat: nil, long: nil, radius: 0)
        XCTAssertFalse(viewModel.isGeofenceModelValid(geofenceModel), "Expected false for invalid location.")
    }
    
    func test_isGeofenceModelValid_withInvalidRadius() throws {
        let geofenceModel = GeofenceDataModel(id: "TestGeofence", lat: 0, long: 0, radius: nil)
        XCTAssertFalse(viewModel.isGeofenceModelValid(geofenceModel), "Expected false for invalid radius.")
    }
    
    func test_deleteData_withoutID() throws {
        let geofenceModel = GeofenceDataModel(id: nil, lat: 0, long: 0, radius: 0)
        viewModel.deleteData(with: geofenceModel)
        
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, StringConstant.geofenceNoIdentifier)
        XCTAssertNil(viewModelDelegate.alertMock.alertModel?.okHandler)
    }
    
    func test_deleteData_declined() throws {
        let defaultGeofenceList = [testGeofenceModel]
        setupViewModel(with: defaultGeofenceList)
        
        viewModel.deleteData(with: testGeofenceModel)
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, StringConstant.deleteGeofenceAlertMessage)
        XCTAssertNotNil(viewModelDelegate.alertMock.alertModel?.okHandler)
        XCTAssertEqual(viewModel.activeGeofencesLists.count, defaultGeofenceList.count)
        XCTAssertEqual(viewModel.activeGeofencesLists.first?.id, testGeofenceModel.id)
    }
    
    func test_deleteData_accepted_success() throws {
        let defaultGeofenceList = [testGeofenceModel]
        setupViewModel(with: defaultGeofenceList)
        
        viewModel.deleteData(with: testGeofenceModel)
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, StringConstant.deleteGeofenceAlertMessage)
        XCTAssertNotNil(viewModelDelegate.alertMock.alertModel?.okHandler)
        
        geofenceService.deleteResult = .success(testGeofenceModel.id ?? "")
        viewModelDelegate.alertMock.tapMainActionButton()
        
        XCTWaiter().wait(until: { [weak self] in
            return self?.viewModelDelegate.finishProcessCalled ?? false
        }, timeout: Constants.waitRequestDuration, message: "Delete geofence result should've been received")
        XCTAssertTrue(viewModel.activeGeofencesLists.isEmpty)
    }
    
    func test_deleteData_accepted_failure() throws {
        let defaultGeofenceList = [testGeofenceModel]
        setupViewModel(with: defaultGeofenceList)
        
        viewModel.deleteData(with: testGeofenceModel)
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, StringConstant.deleteGeofenceAlertMessage)
        XCTAssertNotNil(viewModelDelegate.alertMock.alertModel?.okHandler)
        
        geofenceService.deleteResult = .failure(defaultError)
        viewModelDelegate.alertMock.tapMainActionButton()
        
        XCTWaiter().wait(until: { [weak self] in
            return self?.viewModelDelegate.alertMock.showAlertCalled ?? false
        }, timeout: Constants.waitRequestDuration, message: "Error alert should've been displayed")
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, defaultError.localizedDescription)
    }
}
