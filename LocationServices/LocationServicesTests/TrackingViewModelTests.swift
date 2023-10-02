//
//  TrackingViewModelTests.swift
//  LocationServicesTests
//
//  Created by Zeeshan Sheikh on 26/09/2023.
//

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
        static let updateGeofenceRadius: Int = 30
        
        
        static var geofence: GeofenceDataModel {
            return GeofenceDataModel(id: cityName, lat: geofenceLatitude, long: geofenceLongitude, radius: Int64(geofenceRadius))
        }
        
//        static var trackingHistory: TrackingHistoryPresentation {
//            return TrackingHistoryPresentation(model: AWSLocationDevicePosition , stepType: .first)
//        }
        
        static var updatedGeofence: GeofenceDataModel {
            return GeofenceDataModel(id: cityName, lat: updateGeofenceLatitude, long: updateGeofenceLongitude, radius: Int64(updateGeofenceRadius))
        }
        
        static let defaultError = NSError(domain: "Tracking error", code: -1)
    }
    
    let userLocation = (lat: 40.7487776237092, long: -73.98554260340953)
    let apiTrackingService = TrackingAPIServiceMock(delay: Constants.apiRequestDuration)
    let apiGeofenceService = GeofenceAPIServiceMock(delay: Constants.apiRequestDuration)
    var viewModel: TrackingViewModel!
    var delegate: MockTrackingViewModelDelegate!
    
    override func setUp() {
        super.setUp()
        viewModel = TrackingViewModel(trackingService: apiTrackingService, geofenceService: apiGeofenceService)
        delegate = MockTrackingViewModelDelegate()
        viewModel.delegate = delegate
    }
    
    func testStartTracking() throws {
        viewModel.startTracking()
        XCTAssertEqual(viewModel.isTrackingActive, true, "Expected isTrackingActive true")
    }
    
    func testStopTracking() throws {
        viewModel.stopTracking()
        XCTAssertEqual(viewModel.isTrackingActive, false, "Expected isTrackingActive false")
    }
    
    func testTrackLocationUpdate() throws {
        apiTrackingService.putResult = .success(())
        apiTrackingService.getResult = .success([])
        viewModel.startTracking()
        viewModel.trackLocationUpdate(location: CLLocation(latitude: userLocation.lat, longitude: userLocation.long))
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasDrawnTrack ?? false
        }, timeout: Constants.waitRequestDuration, message: "Tracking history should`ve been loaded")
    }
    
    func testTrackLocationUpdateFailure() throws {
        apiTrackingService.putResult = .failure(Constants.defaultError)
        apiTrackingService.getResult = .failure(Constants.defaultError)
        viewModel.startTracking()
        viewModel.trackLocationUpdate(location: CLLocation(latitude: userLocation.lat, longitude: userLocation.long))
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasShownAlert ?? false
        }, timeout: Constants.waitRequestDuration, message: "Tracking history should`ve failed")
    }
    
    func testFetchListOfGeofencesEmpty() throws {
        UserDefaultsHelper.setAppState(state: .initial)
        apiGeofenceService.getResult = .success([Constants.geofence])
        viewModel.fetchListOfGeofences()
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasShownGeofences ?? false
        }, timeout: Constants.waitRequestDuration, message: "Geofence data is empty")
    }

    func testFetchListOfGeofences() throws {
        UserDefaultsHelper.setAppState(state: .loggedIn)
        apiGeofenceService.getResult = .success([Constants.geofence])
        viewModel.fetchListOfGeofences()
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasShownGeofences ?? false
        }, timeout: Constants.waitRequestDuration, message: "Geofence data should`ve been loaded")
    }
    
    func testFetchListOfGeofencesFailure() throws {
        UserDefaultsHelper.setAppState(state: .loggedIn)
        apiGeofenceService.getResult = .failure(Constants.defaultError)
        viewModel.fetchListOfGeofences()
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasShownAlert ?? false
        }, timeout: Constants.waitRequestDuration, message: "Geofence data should`ve failed")
    }
    
    func testUpdateHistory() throws {
        apiTrackingService.getResult = .success([])
        viewModel.updateHistory()
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasHistoryLoaded ?? false
        }, timeout: Constants.waitRequestDuration, message: "Tracking history should`ve been loaded")
    }
    
    func testUpdateHistoryFailure() throws {
        apiTrackingService.getResult = .failure(Constants.defaultError)
        viewModel.updateHistory()
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasShownAlert ?? false
        }, timeout: Constants.waitRequestDuration, message: "Tracking history should`ve shown error alert")
    }
    
    func testResetHistory() throws {
        viewModel.resetHistory()
        XCTAssertEqual(viewModel.hasHistory, false, "Expecting empty history")
    }
}

class MockTrackingViewModelDelegate : TrackingViewModelDelegate {

    var hasDrawnTrack = false
    var hasHistoryLoaded = false
    var hasShownGeofences = false
    var hasShownAlert = false
    
    func drawTrack(history: [LocationServices.TrackingHistoryPresentation]) {
        hasDrawnTrack = true
    }
    
    func historyLoaded() {
        hasHistoryLoaded = true
    }
    
    func showGeofences(_ models: [LocationServices.GeofenceDataModel]) {
        hasShownGeofences = true
    }
    
    func showAlert(_ model: LocationServices.AlertModel) {
        hasShownAlert = true
    }
    
}
