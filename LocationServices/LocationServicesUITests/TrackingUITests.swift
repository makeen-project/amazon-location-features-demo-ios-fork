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
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    func testTrackingSimulation() throws {
        let app = startApp(allowPermissions: true)
        
        _ = UITestTabBarScreen(app: app)
            .tapTrackingButton()
            .tapStartTrackingSimulationButton()
            .waitForTrackingPoints()
            .tapStartTrackingButton()
            .waitForTrackingSimulation()
    }
}

