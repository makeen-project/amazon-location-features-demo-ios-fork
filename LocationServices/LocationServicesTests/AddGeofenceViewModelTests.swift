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
        static let geofenceRadius: Int = 20
        
        static let updatedGeofenceLat: TimeInterval = 15
        static let updatedGeofenceLong: TimeInterval = 10
        static let updatedGeofenceRadius: Int = 25
        
        static var testGeofenceModel: GeofenceDataModel {
            return GeofenceDataModel(id: geofenceId, lat: geofenceLat, long: geofenceLong, radius: Int64(geofenceRadius))
        }
        static let defaultError = NSError(domain: "Geofence error", code: -1)
    }
    
    var viewModel: AddGeofenceViewModel!
    var geofenceService: GeofenceAPIServiceMock!
    var locationService: LocationAPIServiceMock!
    var viewModelDelegate: AddGeofenceViewModelOutputProtocolMock!
    
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
        let defaultGeofenceList = [Constants.testGeofenceModel]
        setupViewModel(with: defaultGeofenceList)
        
        viewModel.deleteData(with: Constants.testGeofenceModel)
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, StringConstant.deleteGeofenceAlertMessage)
        XCTAssertNotNil(viewModelDelegate.alertMock.alertModel?.okHandler)
        XCTAssertEqual(viewModel.activeGeofencesLists.count, defaultGeofenceList.count)
        XCTAssertEqual(viewModel.activeGeofencesLists.first?.id, Constants.geofenceId)
    }
    
    func test_deleteData_accepted_success() throws {
        let defaultGeofenceList = [Constants.testGeofenceModel]
        setupViewModel(with: defaultGeofenceList)
        
        viewModel.deleteData(with: Constants.testGeofenceModel)
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, StringConstant.deleteGeofenceAlertMessage)
        XCTAssertNotNil(viewModelDelegate.alertMock.alertModel?.okHandler)
        
        geofenceService.deleteResult = .success(Constants.geofenceId)
        viewModelDelegate.alertMock.tapMainActionButton()
        
        XCTWaiter().wait(until: { [weak self] in
            return self?.viewModelDelegate.finishProcessCalled ?? false
        }, timeout: Constants.waitRequestDuration, message: "Delete geofence result should've been received")
        XCTAssertTrue(viewModel.activeGeofencesLists.isEmpty)
    }
    
    func test_deleteData_accepted_failure() throws {
        let defaultGeofenceList = [Constants.testGeofenceModel]
        setupViewModel(with: defaultGeofenceList)
        
        viewModel.deleteData(with: Constants.testGeofenceModel)
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, StringConstant.deleteGeofenceAlertMessage)
        XCTAssertNotNil(viewModelDelegate.alertMock.alertModel?.okHandler)
        
        geofenceService.deleteResult = .failure(Constants.defaultError)
        viewModelDelegate.alertMock.tapMainActionButton()
        
        XCTWaiter().wait(until: { [weak self] in
            return self?.viewModelDelegate.alertMock.showAlertCalled ?? false
        }, timeout: Constants.waitRequestDuration, message: "Error alert should've been displayed")
        XCTAssertEqual(viewModelDelegate.alertMock.alertModel?.message, Constants.defaultError.localizedDescription)
    }
    
    func test_saveData_new_succeed() throws {
        geofenceService.putResult = .success(Constants.testGeofenceModel)
        
        let expectation = expectation(description: "Save data completion should be called")
        var saveResult: Result<GeofenceDataModel, Error>? = nil
        viewModel.saveData(with: Constants.geofenceId, lat: Constants.geofenceLat, long: Constants.geofenceLong, radius: Constants.geofenceRadius) { result in
            saveResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: Constants.waitRequestDuration)
        
        switch saveResult {
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
        case .none:
            XCTFail("Result is nil")
        }
    }
    
    func test_saveData_new_failure() throws {
        geofenceService.putResult = .failure(Constants.defaultError)
        
        let expectation = expectation(description: "Save data completion should be called")
        var saveResult: Result<GeofenceDataModel, Error>? = nil
        viewModel.saveData(with: Constants.geofenceId, lat: Constants.geofenceLat, long: Constants.geofenceLong, radius: Constants.geofenceRadius) { result in
            saveResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: Constants.waitRequestDuration)
        
        switch saveResult {
        case .success:
            XCTFail("Result should be failure")
        case .failure(let error):
            XCTAssertEqual(error as NSError, Constants.defaultError)
            XCTAssertEqual(viewModel.activeGeofencesLists.count, 0)
        case .none:
            XCTFail("Result is nil")
        }
    }
    
    func test_saveData_old_succeed() throws {
        let defaultGeofenceList = [Constants.testGeofenceModel]
        setupViewModel(with: defaultGeofenceList)
        
        let updatedGeofence = GeofenceDataModel(id: Constants.geofenceId, lat: Constants.updatedGeofenceLat, long: Constants.updatedGeofenceLong, radius: Int64(Constants.updatedGeofenceRadius))
        geofenceService.putResult = .success(updatedGeofence)
        
        let expectation = expectation(description: "Save data completion should be called")
        var saveResult: Result<GeofenceDataModel, Error>? = nil
        viewModel.saveData(with: Constants.geofenceId, lat: Constants.updatedGeofenceLat, long: Constants.updatedGeofenceLong, radius: Constants.updatedGeofenceRadius) { result in
            saveResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: Constants.waitRequestDuration)
        
        switch saveResult {
        case .success(let geofenceModel):
            XCTAssertEqual(viewModel.activeGeofencesLists.count, 1)
            let firstModel = try XCTUnwrap(viewModel.activeGeofencesLists.first)
            [firstModel, geofenceModel].forEach { model in
                XCTAssertEqual(model.id, Constants.testGeofenceModel.id)
                XCTAssertEqual(model.lat, Constants.updatedGeofenceLat)
                XCTAssertEqual(model.long, Constants.updatedGeofenceLong)
                XCTAssertEqual(model.radius, Int64(Constants.updatedGeofenceRadius))
            }
        case .failure:
            XCTFail("Result should be success")
        case .none:
            XCTFail("Result is nil")
        }
    }
    
    func test_saveData_old_failure() throws {
        let defaultGeofenceList = [Constants.testGeofenceModel]
        setupViewModel(with: defaultGeofenceList)
        
        geofenceService.putResult = .failure(Constants.defaultError)
        let expectation = expectation(description: "Save data completion should be called")
        var saveResult: Result<GeofenceDataModel, Error>? = nil
        viewModel.saveData(with: Constants.geofenceId, lat: Constants.updatedGeofenceLat, long: Constants.updatedGeofenceLong, radius: Constants.updatedGeofenceRadius) { result in
            saveResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: Constants.waitRequestDuration)
        
        switch saveResult {
        case .success:
            XCTFail("Result should be failure")
        case .failure(let error):
            XCTAssertEqual(error as NSError, Constants.defaultError)
            XCTAssertEqual(viewModel.activeGeofencesLists.count, 1)
        case .none:
            XCTFail("Result is nil")
        }
    }
}
