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

    func connectAWSAccount() throws -> XCUIApplication {
        let app = startApp()
        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapConnectAWSRow()
            .connectAWSConnect()
        return app
    }
}
