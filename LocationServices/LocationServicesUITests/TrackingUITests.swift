//
//  AWSConnectUITests.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
import Foundation
import CoreLocation

final class TrackingUITests: LocationServicesUITests {
    
    enum Constants {
        static let geofenceCoordinates = CLLocation(latitude: 40.759223,longitude: -73.984628)
        static let geofenceLocationAddress = "Theater District, New York, NY, USA"
        static let trackingPoints: [CLLocation] = [
            CLLocation(latitude: 40.71464476038106, longitude:  -74.00498982173545),
            CLLocation(latitude: 40.732548437941425, longitude:  -73.99963509081488)
        ]
        
    }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    func testStartTracking() throws {
        var app = startApp()
        
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .connectAWSConnect()

        app = restartApp()
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .signInAWSAccount()
        
        let _ = UITestGeofenceScreen(app: app)
            .deleteAllGeofences()
        
        app = restartApp()
        
        _ = UITestTabBarScreen(app: app)
            .tapTrackingButton()
            .tapEnableTrackingButton()
            .tapStartTrackingButton()
            .continueTrackingAlert()
            .verifyTrackingStartedLabel()
    }
    
    func testStopTracking() throws {
        var app = startApp()
        
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .connectAWSConnect()

        app = restartApp()
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .signInAWSAccount()
        
        let _ = UITestGeofenceScreen(app: app)
            .deleteAllGeofences()
        
        app = restartApp()
        
        _ = UITestTabBarScreen(app: app)
            .tapTrackingButton()
            .tapEnableTrackingButton()
            .tapStartTrackingButton()
            .continueTrackingAlert()
            .verifyTrackingStartedLabel()
            .tapStopTrackingButton()
            .verifyTrackingStoppedLabel()
    }
    
    func testStartTrackingHistoryStarted() throws {
        var app = startApp()
        
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .connectAWSConnect()

        app = restartApp()
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .signInAWSAccount()
        
        let _ = UITestGeofenceScreen(app: app)
            .deleteAllGeofences()
        
        app = restartApp()
        
        let uiTrackingScreen = UITestTabBarScreen(app: app)
            .tapTrackingButton()
            .tapEnableTrackingButton()
            .tapStartTrackingButton()
            .continueTrackingAlert()
        
        Thread.sleep(forTimeInterval: 1)
        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[1])
        
        _ = uiTrackingScreen
            .verifyTrackingHistoryStarted()
    }
    
    func testTrackingPointsOnMap() throws {
        var app = startApp()
        
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .connectAWSConnect()

        app = restartApp()
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .signInAWSAccount()

        let _ = UITestGeofenceScreen(app: app)
            .deleteAllGeofences()

        app = restartApp()
        
        let uiTrackingScreen = UITestTabBarScreen(app: app)
            .tapTrackingButton()
            .tapEnableTrackingButton()
            .tapStartTrackingButton()
            .continueTrackingAlert()
        
            XCUIDevice.shared.location = .init(location: Constants.trackingPoints[0])
            Thread.sleep(forTimeInterval: 1) // Delay between updates
            XCUIDevice.shared.location = .init(location: Constants.trackingPoints[1])
            Thread.sleep(forTimeInterval: 1)
            XCUIDevice.shared.location = .init(location: Constants.trackingPoints[0])
            Thread.sleep(forTimeInterval: 1)
        XCUIDevice.shared.location = .init(location: Constants.geofenceCoordinates)
        Thread.sleep(forTimeInterval: 2)

        
        _ = uiTrackingScreen
            .verifyTrackingAnnotations()
        
    }
    
    func testTrackingNotifyEnteredGeofence() throws {
        var app = startApp()
        
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .connectAWSConnect()

        app = restartApp()
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .signInAWSAccount()
        
        let _ = UITestGeofenceScreen(app: app)
            .deleteAllGeofences()
        
        app = restartApp()
        
        let geofenceName = UITestGeofenceScreen.generateUniqueGeofenceName()
        
        _ = UITestTabBarScreen(app: app)
            .tapGeofenceButton()
            .addGeofence(geofenceNameToAdd: geofenceName, location: Constants.geofenceLocationAddress, selectDefault: true)
        
        app = restartApp()
        
        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[0])
        
        let trackingUIScreen = UITestTabBarScreen(app: app)
            .tapTrackingButton()
            .tapEnableTrackingButton()
            .tapStartTrackingButton()
            .continueTrackingAlert()
        
        Thread.sleep(forTimeInterval: 2)
        XCUIDevice.shared.location = .init(location: Constants.geofenceCoordinates)
        
        let _ = trackingUIScreen
            .waitForGeofenceEnteredAlert(geofenceName: geofenceName)
    }
    
    func testTrackingNotifyExitedGeofence() throws {
        
        var app = startApp()
        
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .connectAWSConnect()

        app = restartApp()
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .signInAWSAccount()
        
        let _ = UITestGeofenceScreen(app: app)
            .deleteAllGeofences()
        
        app = restartApp()

        let geofenceName = UITestGeofenceScreen.generateUniqueGeofenceName()
        
        _ = UITestTabBarScreen(app: app)
            .tapGeofenceButton()
            .addGeofence(geofenceNameToAdd: geofenceName,location: Constants.geofenceLocationAddress, selectDefault: true)

        app = restartApp()
        
        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[0])
        
        let trackingUIScreen = UITestTabBarScreen(app: app)
            .tapTrackingButton()
            .tapEnableTrackingButton()
            .tapStartTrackingButton()
            .continueTrackingAlert()
        
        Thread.sleep(forTimeInterval: 2)
        XCUIDevice.shared.location = .init(location: Constants.geofenceCoordinates)
        
        let _ = trackingUIScreen
            .waitForGeofenceEnteredAlert(geofenceName: geofenceName)

        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[0])

        let _ = trackingUIScreen
            .waitForGeofenceExitedAlert(geofenceName: geofenceName)
    }
    
    func testTrackingDeleteHistoryLog() throws {
        
        var app = startApp()
        
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .connectAWSConnect()

        app = restartApp()
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .signInAWSAccount()
        
        let _ = UITestGeofenceScreen(app: app)
            .deleteAllGeofences()
        
        app = restartApp()
        
        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[0])
        let trackingUIScreen = UITestTabBarScreen(app: app)
            .tapTrackingButton()
            .tapEnableTrackingButton()
            .tapStartTrackingButton()
            .continueTrackingAlert()
        
        Thread.sleep(forTimeInterval: 1)
        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[1])

        let _ = trackingUIScreen
            .tapStopTrackingButton()
            .verifyTrackingStoppedLabel()
            .tapDeleteTrackingDataButton()
            .verifyTrackingHistoryDeleted()
    }
}

