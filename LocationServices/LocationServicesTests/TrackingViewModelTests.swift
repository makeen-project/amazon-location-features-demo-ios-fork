//
//  TrackingViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices
import CoreLocation

final class TrackingViewModelTests: XCTestCase {
    
    enum Constants {
        static let apiRequestDuration: Double = 1
        static let waitRequestDuration: Double = 10
        
        static let cityName = "New York"
        static let geofenceLatitude: Double = 12
        static let geofenceLongitude: Double = 13
        static let geofenceRadius: Int = 50
        
        static let updateGeofenceLatitude: Double = 15
        static let updateGeofenceLongitude: Double = 20
        static let updateGeofenceRadius: Double = 30
        
        
        static var geofence: GeofenceDataModel {
            return GeofenceDataModel(id: cityName, lat: geofenceLatitude, long: geofenceLongitude, radius: Double(geofenceRadius))
        }
        
        static var updatedGeofence: GeofenceDataModel {
            return GeofenceDataModel(id: cityName, lat: updateGeofenceLatitude, long: updateGeofenceLongitude, radius: updateGeofenceRadius)
        }
        
        static let defaultError = NSError(domain: "Tracking error", code: -1)
    }
    
    
    let userLocation = (lat: 40.7487776237092, long: -73.98554260340953)
    let apiGeofenceService = GeofenceAPIServiceMock(delay: Constants.apiRequestDuration)
    var viewModel: TrackingViewModel!
    var delegate: MockTrackingViewModelDelegate!
    
    override func setUp() {
        super.setUp()
        viewModel = TrackingViewModel(geofenceService: apiGeofenceService)
        delegate = MockTrackingViewModelDelegate()
        viewModel.delegate = delegate
    }
    
    func testStartTrackingSimulation() throws {
        
    }
}

class MockTrackingViewModelDelegate : TrackingViewModelDelegate {
    func drawTrackingRoute(routeId: String, coordinates: [CLLocationCoordinate2D]) {
        hasDrawnTrackingRoute = true
    }
    
    func showGeofences(routeId: String, _ models: [LocationServices.GeofenceDataModel]) {
        hasShownGeofences = true
    }
    

    var hasDrawnTrackingRoute = false
    var hasShownGeofences = false
    var hasShownAlert = false
    
    func showAlert(_ model: LocationServices.AlertModel) {
        hasShownAlert = true
    }
    
}
