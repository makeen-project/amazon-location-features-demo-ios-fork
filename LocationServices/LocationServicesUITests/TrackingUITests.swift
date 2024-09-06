//
//  AWSConnectUITests.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
import Foundation
import CoreLocation
import WebKit

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
        clearSafariSessionData()
    }
    
    func clearSafariSessionData() {
        // Clear cookies
        let cookieStore = HTTPCookieStorage.shared
        if let cookies = cookieStore.cookies {
            for cookie in cookies {
                cookieStore.deleteCookie(cookie)
            }
        }

        // Clear website data like cache, storage, etc.
        let dataStore = WKWebsiteDataStore.default()
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        
        let dateFrom = Date(timeIntervalSince1970: 0)
        dataStore.removeData(ofTypes: dataTypes, modifiedSince: dateFrom) {
            print("Safari data cleared")
        }
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    func disabledtestStartTracking() throws {
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
    
    func disabledtestStopTracking() throws {
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
    
    func disabledtestStartTrackingHistoryStarted() throws {
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
    
    func disabledtestTrackingPointsOnMap() throws {
        var app = startApp()
        
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .connectAWSConnect()

        app = restartApp()
        let menuScreen = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .signInAWSAccount()
        
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            menuScreen.getBackButton().tap()
        }

        let _ = UITestGeofenceScreen(app: app)
            .deleteAllGeofences()

        app = restartApp()
        
        let uiTrackingScreen = UITestTabBarScreen(app: app)
            .tapTrackingButton()
            .tapEnableTrackingButton()
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
    
    func disabledtestTrackingNotifyEnteredGeofence() throws {
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
    
    func testTrackingGeofenceE2E() throws {
        
        var app = startApp()
        
        let menuScreen = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .connectAWSConnect()
            .signInAWSAccount()
        
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            menuScreen.getBackButton().tap()
        }
        
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
            .continueTrackingAlert()
        
        Thread.sleep(forTimeInterval: 2)
        XCUIDevice.shared.location = .init(location: Constants.geofenceCoordinates)
        
        let _ = trackingUIScreen
            .waitForGeofenceEnteredAlert(geofenceName: geofenceName)

        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[0])
        Thread.sleep(forTimeInterval: 2)
        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[1])
        Thread.sleep(forTimeInterval: 2)
        
        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[0])
        Thread.sleep(forTimeInterval: 1)
        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[1])
        Thread.sleep(forTimeInterval: 1)
        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[0])
        Thread.sleep(forTimeInterval: 1)
        XCUIDevice.shared.location = .init(location: Constants.geofenceCoordinates)
        Thread.sleep(forTimeInterval: 2)

    
    _ = trackingUIScreen
        .verifyTrackingAnnotations()
        
        let _ = trackingUIScreen
            .waitForGeofenceExitedAlert(geofenceName: geofenceName)
        
        Thread.sleep(forTimeInterval: 1)
        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[1])

        let _ = trackingUIScreen
            .tapStopTrackingButton()
            .verifyTrackingStoppedLabel()
            .swipeUpHistoryView()
            .tapDeleteTrackingDataButton()
            .verifyTrackingHistoryDeleted()
        
        let newGeofenceName = UITestGeofenceScreen.generateUniqueGeofenceName()
        
        _ = UITestTabBarScreen(app: app)
            .tapGeofenceButton()
            .editGeofence(geofenceName: geofenceName, newGeofenceName: newGeofenceName)
            .deleteGeofence(index: 0)
            .confirmDeleteGeofence()
            .verifyDeletedGeofence(geofenceName: newGeofenceName)
    }
    
    func disabledtestTrackingDeleteHistoryLog() throws {
        
        var app = startApp()
        
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .connectAWSConnect()

        app = restartApp()
        let menuScreen = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .signInAWSAccount()
        
        if(UIDevice.current.userInterfaceIdiom == .phone) {
            menuScreen.getBackButton().tap()
        }
        
        let _ = UITestGeofenceScreen(app: app)
            .deleteAllGeofences()
        
        app = restartApp()
        
        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[0])
        let trackingUIScreen = UITestTabBarScreen(app: app)
            .tapTrackingButton()
            .tapEnableTrackingButton()
            .continueTrackingAlert()
        
        Thread.sleep(forTimeInterval: 1)
        XCUIDevice.shared.location = .init(location: Constants.trackingPoints[1])

        let _ = trackingUIScreen
            .tapStopTrackingButton()
            .verifyTrackingStoppedLabel()
            .swipeUpHistoryView()
            .tapDeleteTrackingDataButton()
            .verifyTrackingHistoryDeleted()
    }
}

