//
//  GeofenceUITests.swift
//  GeofenceUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

final class GeofenceUITests: LocationServicesUITests {
    
    enum Constants {
        static let geofenceName = "testgeo"
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    func disabledtestAddGeofence() throws {
        
        var app = startApp()
        let geofenceName = UITestGeofenceScreen.generateUniqueGeofenceName()
        
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
        
        let _ = UITestGeofenceScreen(app: app)
            .addGeofence(geofenceNameToAdd: geofenceName)
    }
    
    func disabledtestDeleteGeofence() throws {
        var app = startApp()
        let geofenceName = UITestGeofenceScreen.generateUniqueGeofenceName()
        
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
        
        let _ = UITestGeofenceScreen(app: app)
            .addGeofence(geofenceNameToAdd: geofenceName)
            .deleteGeofence(geofenceName: geofenceName)
            .confirmDeleteGeofence()
            .verifyDeletedGeofence(geofenceName: geofenceName)
    }
    
    
    func disabledtestEditGeofence() throws {
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
        
        let geofenceName = UITestGeofenceScreen.generateUniqueGeofenceName()
        let newGeofenceName = UITestGeofenceScreen.generateUniqueGeofenceName()
        
        let _ = UITestGeofenceScreen(app: app)
            .addGeofence(geofenceNameToAdd: geofenceName)
            .editGeofence(geofenceName: geofenceName, newGeofenceName: newGeofenceName)
    }
    
    func disabledtestEditAndDeleteGeofence() throws {
        var app = startApp()

        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .connectAWSConnect()

        let menuScreen = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .signInAWSAccount()

        if(UIDevice.current.userInterfaceIdiom == .phone) {
            menuScreen.getBackButton().tap()
        }
        
        let _ = UITestGeofenceScreen(app: app)
            .deleteAllGeofences()
        
        let geofenceName = UITestGeofenceScreen.generateUniqueGeofenceName()
        let newGeofenceName = UITestGeofenceScreen.generateUniqueGeofenceName()
        
        let _ = UITestGeofenceScreen(app: app)
            .addGeofence(geofenceNameToAdd: geofenceName)
            .editGeofence(geofenceName: geofenceName, newGeofenceName: newGeofenceName)
            .deleteGeofence(index: 0)
            .confirmDeleteGeofence()
            .verifyDeletedGeofence(geofenceName: newGeofenceName)
    }
}
