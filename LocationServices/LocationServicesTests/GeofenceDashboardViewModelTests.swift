//
//  GeofenceDashboardViewModel.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class GeofenceDashboardViewModelTests: XCTestCase {
    
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
            return GeofenceDataModel(id: cityName, lat: geofenceLatitude, long: geofenceLongitude, radius: geofenceRadius)
        }
        
        static var updatedGeofence: GeofenceDataModel {
            return GeofenceDataModel(id: cityName, lat: updateGeofenceLatitude, long: updateGeofenceLongitude, radius: updateGeofenceRadius)
        }
        
        static let defaultError = NSError(domain: "Geofence error", code: -1)
    }
    
    let apiService = GeofenceAPIServiceMock(delay: Constants.apiRequestDuration)
    var viewModel: GeofenceDashboardViewModel!
    var delegate: GeofenceDasboardViewModelOutputProtocolMock!
    
    override func setUp() {
        super.setUp()
        viewModel = GeofenceDashboardViewModel(geofenceService: apiService)
        delegate = GeofenceDasboardViewModelOutputProtocolMock()
        viewModel.delegate = delegate
    }
    
    func testFetchListOfGeofences() async throws {
        UserDefaultsHelper.setAppState(state: .loggedIn)
        await viewModel.fetchListOfGeofences()
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasRefreshedData ?? false
        }, timeout: Constants.waitRequestDuration, message: "Geofence data should`ve been loaded")
    }
    
    func testFetchListOfGeofencesFailure() async throws {
        UserDefaultsHelper.setAppState(state: .loggedIn)
        apiService.mockGetGeofenceListResult = .failure(Constants.defaultError)
        await viewModel.fetchListOfGeofences()
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasShownAlert ?? false
        }, timeout: Constants.waitRequestDuration, message: "Geofence error should've shown")
    }
    
    func testDeleteGeofenceDataWithoutID() throws {
        UserDefaultsHelper.setAppState(state: .loggedIn)
        let geofenceModel = GeofenceDataModel(id: nil, lat: Constants.geofenceLatitude, long: Constants.geofenceLongitude, radius: Constants.geofenceRadius)
        viewModel.deleteGeofenceData(model: Constants.geofence )
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasShownAlert ?? false
        }, timeout: Constants.waitRequestDuration, message: "Geofence data should`ve been loaded")
    }
    
    func testDeleteGeofenceData() throws {
        UserDefaultsHelper.setAppState(state: .loggedIn)
        viewModel.deleteGeofenceData(model: Constants.geofence )
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasShownAlert ?? false
        }, timeout: Constants.waitRequestDuration, message: "Geofence data should`ve been deleted")
    }
    
    func testDeleteGeofenceDataFailure() throws {
        UserDefaultsHelper.setAppState(state: .loggedIn)
        apiService.mockDeleteGeofenceResult = .failure(Constants.defaultError)
        viewModel.deleteGeofenceData(model: Constants.geofence )
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasShownAlert ?? false
        }, timeout: Constants.waitRequestDuration, message: "Geofence error should've shown")
    }

}

class GeofenceDasboardViewModelOutputProtocolMock : GeofenceDasboardViewModelOutputProtocol {
    var hasRefreshedData = false
    var hasShownAlert = false
    func refreshData(with model: [LocationServices.GeofenceDataModel]) {
        hasRefreshedData = true
    }
    
    func showAlert(_ model: LocationServices.AlertModel) {
        hasShownAlert = true
    }
    
    
}
