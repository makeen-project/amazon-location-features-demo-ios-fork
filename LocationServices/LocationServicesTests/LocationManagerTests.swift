//
//  LocationManagerTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices
import CoreLocation

class LocationManagerTests: XCTestCase {
    var locationManager: LocationManager!
    var mockLocationManager: MockCLLocationManager!
    var mockAlertPresenter: MockAlertPresenter!
    
    override func setUp() {
        super.setUp()
        mockLocationManager = MockCLLocationManager()
        mockAlertPresenter = MockAlertPresenter()
        locationManager = LocationManager(alertPresenter: mockAlertPresenter, locationManager: mockLocationManager)
    }
    
    override func tearDown() {
        super.tearDown()
        mockLocationManager = nil
        mockAlertPresenter = nil
        locationManager = nil
    }
    
    func testGetAuthorizationStatus() {
        mockLocationManager.authorizationStatus = .authorizedAlways
        XCTAssertEqual(locationManager.getAuthorizationStatus(), .authorizedAlways)
    }
    
    func testsetDelegate() {
        let mockDelegate = MockCLLocationManagerDelegate()
        locationManager.setDelegate(mockDelegate)
        XCTAssertEqual(mockLocationManager.delegate as? MockCLLocationManagerDelegate, mockDelegate)
    }
    
    func testStartUpdatingLocationWithPermissions() {
        locationManager.startUpdatingLocation()
        XCTAssertTrue(mockLocationManager.didStartUpdatingLocation)
        XCTAssertTrue(mockLocationManager.didStartUpdatingHeading)
    }
    
    func testStartUpdatingLocationWithoutPermissions() {
        mockLocationManager.authorizationStatus = .notDetermined
        locationManager.startUpdatingLocation()
        XCTAssertFalse(mockLocationManager.didStartUpdatingLocation)
        XCTAssertFalse(mockLocationManager.didStartUpdatingHeading)
    }
    
    func testStartUpdatingLocationWithDeclinedPermissions() {
        mockLocationManager.authorizationStatus = .denied
        locationManager.startUpdatingLocation()
        XCTAssertFalse(mockLocationManager.didStartUpdatingLocation)
        XCTAssertFalse(mockLocationManager.didStartUpdatingHeading)
    }
    
    func testRequestPermissionsWithGrantedAccess() {
        mockLocationManager.authorizationStatus = .authorizedAlways
        locationManager.requestPermissions()
        XCTAssertFalse(mockAlertPresenter.didShowAlert)
    }
    
    func testRequestPermissionsWithDeniedAccess() {
        mockLocationManager.authorizationStatus = .denied
        locationManager.requestPermissions()
        XCTAssertTrue(mockAlertPresenter.didShowAlert)
    }
    
    func testRequestPermissionsWithNotDeterminedAccess() {
        mockLocationManager.authorizationStatus = .notDetermined
        locationManager.requestPermissions()
        XCTAssertFalse(mockAlertPresenter.didShowAlert)
        XCTAssertTrue(mockLocationManager.didRequestWhenInUseAuthorization)
        
        mockLocationManager.authorizationStatus = .authorizedWhenInUse
        XCTAssertEqual(locationManager.getAuthorizationStatus(), .authorizedWhenInUse)
    }

    func testPerformLocationDependentActionWithGrantedAccess() {
        mockLocationManager.authorizationStatus = .authorizedWhenInUse
        
        let expectation = XCTestExpectation(description: "Location dependent action should be performed")
        locationManager.performLocationDependentAction {
            expectation.fulfill()
        }
        
        XCTAssertFalse(mockAlertPresenter.didShowAlert)
        wait(for: [expectation], timeout: 1)
    }
    
    func testPerformLocationDependentActionWithoutGrantedAccess() {
        mockLocationManager.authorizationStatus = .notDetermined
        
        let expectation = XCTestExpectation(description: "Location dependent action should not be performed")
        expectation.isInverted = true
        locationManager.performLocationDependentAction {
            expectation.fulfill()
        }
        
        XCTAssertFalse(mockAlertPresenter.didShowAlert)
        XCTAssertTrue(mockLocationManager.didRequestWhenInUseAuthorization)
        wait(for: [expectation], timeout: 1)
    }
}

class MockCLLocationManager: CLLocationManagerProtocol {
    var authorizationStatus: CLAuthorizationStatus = .authorizedAlways
    var delegate: CLLocationManagerDelegate?
    var didStartUpdatingLocation = false
    var didStartUpdatingHeading = false
    var didRequestWhenInUseAuthorization = false
    
    func startUpdatingLocation() {
        guard grantedPermissions() else { return }
        didStartUpdatingLocation = true
    }
    
    func startUpdatingHeading() {
        guard grantedPermissions() else { return }
        didStartUpdatingHeading = true
    }
    
    func requestWhenInUseAuthorization() {
        didRequestWhenInUseAuthorization = true
    }
    
    private func grantedPermissions() -> Bool {
        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            return true
        default:
            return false
        }
    }
}

class MockAlertPresenter: AlertPresentable {
    var didShowAlert = false
    
    func showAlert(_ alertModel: AlertModel) {
        didShowAlert = true
    }
}

class MockCLLocationManagerDelegate: NSObject, CLLocationManagerDelegate {}
