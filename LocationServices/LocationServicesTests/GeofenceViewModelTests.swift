//
//  GeofenceViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class GeofenceViewModelTests: XCTestCase {
    
    enum Constants {
        static let apiRequestDuration: Double = 1
        static let waitRequestDuration: Double = 10
        
        static let cityName = "New York"
        static let geofenceLatitude: Double = 12
        static let geofenceLongitude: Double = 13
        static let geofenceRadius: Double = 50
        
        static let updateGeofenceLatitude: Double = 15
        static let updateGeofenceLongitude: Double = 20
        static let updateGeofenceRadius: Double = 30
        
        static var geofence: GeofenceDataModel {
            return GeofenceDataModel(id: cityName, lat: geofenceLatitude, long: geofenceLongitude, radius: Double(geofenceRadius))
        }
        
        static var updatedGeofence: GeofenceDataModel {
            return GeofenceDataModel(id: cityName, lat: updateGeofenceLatitude, long: updateGeofenceLongitude, radius: Double(updateGeofenceRadius))
        }
        
        static let defaultError = NSError(domain: "Geofence error", code: -1)
    }
    
    let apiService = GeofenceAPIServiceMock(delay: Constants.apiRequestDuration)
    var viewModel: GeofenceViewModel!
    var delegate: GeofenceViewModelDelegateMock!
    
    override func setUp() {
        super.setUp()
        viewModel = GeofenceViewModel(geofenceService: apiService)
        delegate = GeofenceViewModelDelegateMock()
        viewModel.delegate = delegate
    }
    
    func test_hasUserLoggedIn_signedIn() throws {
        UserDefaultsHelper.setAppState(state: .loggedIn)
        let isLoggedIn = viewModel.hasUserLoggedIn()
        XCTAssertTrue(isLoggedIn)
    }
    
    func test_hasUserLoggedIn_signedOut() throws {
        UserDefaultsHelper.setAppState(state: .initial)
        let isLoggedIn = viewModel.hasUserLoggedIn()
        XCTAssertFalse(isLoggedIn)
    }
    
    func test_getGeofence_withEmptyArray() throws {
        let result = viewModel.getGeofence(with: Constants.cityName)
        XCTAssertNil(result)
    }
    
    func test_getGeofence_withoutExistsId() throws {
        viewModel.addGeofence(model: Constants.geofence)
        
        let result = viewModel.getGeofence(with: Constants.cityName + "111")
        XCTAssertNil(result)
    }
    
    func test_getGeofence_withExistsId() throws {
        viewModel.addGeofence(model: Constants.geofence)
        
        let result = viewModel.getGeofence(with: Constants.cityName)
        result?.compare(id: Constants.cityName, lat: Constants.geofenceLatitude, long: Constants.geofenceLongitude, radius: Constants.geofenceRadius)
    }
    
    func test_addGeofence_withNewValue() throws {
        viewModel.addGeofence(model: Constants.geofence)
        XCTAssertEqual(viewModel?.geofences.count, 1)
        
        let result = viewModel.getGeofence(with: Constants.cityName)
        result?.compare(id: Constants.cityName, lat: Constants.geofenceLatitude, long: Constants.geofenceLongitude, radius: Constants.geofenceRadius)
    }
    
    func test_addGeofence_withExistedValue() throws {
        viewModel.addGeofence(model: Constants.geofence)
        XCTAssertEqual(viewModel?.geofences.count, 1)
        
        let result = viewModel.getGeofence(with: Constants.cityName)
        result?.compare(id: Constants.cityName, lat: Constants.geofenceLatitude, long: Constants.geofenceLongitude, radius: Constants.geofenceRadius)
        
        
        viewModel.addGeofence(model: Constants.updatedGeofence)
        XCTAssertEqual(viewModel?.geofences.count, 1)
        
        let updatedResult = viewModel.getGeofence(with: Constants.cityName)
        updatedResult?.compare(id: Constants.cityName, lat: Constants.updateGeofenceLatitude, long: Constants.updateGeofenceLongitude, radius: Constants.updateGeofenceRadius)
    }
    
    func test_fetchListOfGeofences_signedOut() async throws {
        delegate.models = nil
        UserDefaultsHelper.setAppState(state: .initial)
        await viewModel.fetchListOfGeofences()
        XCTAssertNil(delegate?.models)
    }
    
    func test_fetchListOfGeofences_SignedIn_success() async throws {
        UserDefaultsHelper.setAppState(state: .loggedIn)
        
        apiService.mockGetGeofenceListResult = .success([Constants.geofence])
        await viewModel.fetchListOfGeofences()
        
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.showGeofencesCalled ?? false
        }, timeout: Constants.waitRequestDuration, message: "Geofence data should`ve been loaded")
        
        XCTAssertEqual(delegate?.models?.count, 1)
        delegate.models?.first?.compare(id: Constants.cityName, lat: Constants.geofenceLatitude, long: Constants.geofenceLongitude, radius: Constants.geofenceRadius)
    }
    
    func test_fetchListOfGeofences_signedIn_failure() async  throws {
        UserDefaultsHelper.setAppState(state: .loggedIn)
        
        apiService.mockGetGeofenceListResult = .failure(Constants.defaultError)
        await viewModel.fetchListOfGeofences()
        
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.alertMock.showAlertCalled ?? false
        }, timeout: Constants.waitRequestDuration, message: "Error alert should`ve been presented")
        
        XCTAssertNil(delegate?.models)
        XCTAssertEqual(delegate.alertMock.alertModel?.message, Constants.defaultError.localizedDescription)
    }
}
