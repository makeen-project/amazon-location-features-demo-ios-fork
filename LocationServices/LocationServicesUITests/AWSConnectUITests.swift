//
//  AWSConnectUITests.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

final class AWSConnectUITests: LocationServicesUITests {
    
    override func setUp() {
        super.setUp()
    }

    override func tearDownWithError() throws {
        super.tearDown()
    }

    func testConnectAWSAccount() throws {
        let app = startApp()
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .connectAWSConnect()
    }
    
    func testConnectAWSAccountFromTracking() throws {
        let app = startApp()
        let _ = UITestTabBarScreen(app: app)
            .tapTrackingButton()
            .waitForAWSConnectionScreen()
            .connectAWSConnect()
    }
    
    func testConnectAWSAccountFromGeofence() throws {
        let app = startApp()
        let _ = UITestTabBarScreen(app: app)
            .tapGeofenceButton()
            .waitForAWSConnectionScreen()
            .connectAWSConnect()
    }
    
    func testDisconnectAWSAccount() throws {
        try testConnectAWSAccount()
        
        let app = restartApp()
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .tapDisconnectButton()
            .waitForAWSConnectResponse()
        
    }
    
    func testSignInAWSAccount() throws {
        try testConnectAWSAccount()
        
        let app = restartApp()
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .signInAWSAccount()
    }
}
