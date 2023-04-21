//
//  AddGeofenceViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class AddGeofenceViewModelTests: XCTestCase {
    
    var viewModel: AddGeofenceViewModel!
    var geofenceService: GeofenceAPIServiceMock!
    var locationService: LocationAPIServiceMock!
    
    override func setUpWithError() throws {
        geofenceService = GeofenceAPIServiceMock(delay: 1)
        locationService = LocationAPIServiceMock()
        viewModel = AddGeofenceViewModel(searchService: locationService, geofenceService: geofenceService, activeGeofencesLists: [])
    }
    
    override func tearDownWithError() throws {
        geofenceService = nil
        locationService = nil
        viewModel = nil
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
}
