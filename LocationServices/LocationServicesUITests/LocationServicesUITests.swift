//
//  LocationServicesUITests.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
import AWSMobileClientXCF
import CoreLocation

class LocationServicesUITests: XCTestCase {
    
    enum Constants {
        static let springboardIdentifier = "com.apple.springboard"
        static let allowWhileUsingApp = "Allow While Using App"
        static let dontAllow = "Don't Allow"
        static let cfBundleName = "CFBundleName"
        static let uiTestsRunner = " UITests-Runner"
        static let removeApp = "Remove App"
        static let deleteButton = "DeleteButton"
        static let deleteApp = "Delete App"
        static let delete = "Delete"
        
        static let staticLocation = CLLocation(latitude: 40.759223, longitude: -73.984628)
    }
    
    override func setUp() {
        super.setUp()
        declineLocationPersmissions(shouldAssert: false)
        UITestTabBarScreen.resetSideBarState()
        continueAfterFailure = false
        XCUIDevice.shared.location = .init(location: Constants.staticLocation)
        uninstall()
    }
    
    override func tearDown() {
        super.tearDown()
        XCUIApplication().terminate()
    }
    
    func startApp(allowPermissions: Bool = true) -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        
        if allowPermissions {
            allowLocationPersmissions()
        } else {
            declineLocationPersmissions()
        }
        closeWelcomeScreen(app: app)
        return app
    }
    
    func restartApp() -> XCUIApplication {
        UITestTabBarScreen.resetSideBarState()
        let app = XCUIApplication()
        app.terminate()
        app.launch()
        return app
    }

    func closeWelcomeScreen(app: XCUIApplication) {
        let continueButton = app.buttons[ViewsIdentifiers.General.welcomeContinueButton]
        if continueButton.waitForExistence(timeout: UITestWaitTime.regular.time) {
            continueButton.tap()
        }
    }
    
    func allowLocationPersmissions() {
        let springboard = XCUIApplication(bundleIdentifier: Constants.springboardIdentifier)
        let allowBtn = springboard.alerts.buttons.element(boundBy: 1)
        
        if allowBtn.waitForExistence(timeout: UITestWaitTime.long.time) {
            allowBtn.tap()
        } else {
            XCTAssertTrue(false, "Request location permissions alert should be displayed (allow)")
        }
    }
    
    func declineLocationPersmissions(shouldAssert: Bool = true) {
        let springboard = XCUIApplication(bundleIdentifier: Constants.springboardIdentifier)
        let allowBtn = springboard.alerts.buttons.element(boundBy: 2)
        if allowBtn.waitForExistence(timeout: UITestWaitTime.regular.time) {
            allowBtn.tap()
        } else if shouldAssert {
            XCTAssertTrue(false, "Request location permissions alert should be displayed (decline)")
        }
    }
    
    private func uninstall(app: XCUIApplication? = nil, name: String? = nil) {
        (app ?? XCUIApplication()).terminate()

        let timeout = UITestWaitTime.long.time
        let springboard = XCUIApplication(bundleIdentifier: Constants.springboardIdentifier)
        
        let appName: String
        if let name = name {
            appName = name
        } else {
            let uiTestRunnerName = Bundle.main.infoDictionary?[Constants.cfBundleName] as! String
            appName = uiTestRunnerName.replacingOccurrences(of: Constants.uiTestsRunner, with: "")
        }
        springboard.activate()
        /// use `firstMatch` because icon may appear in iPad dock
        let appIcon = springboard.icons[appName].firstMatch
        if appIcon.waitForExistence(timeout: timeout) {
            appIcon.press(forDuration: 2)
        } else {
            //the app hasn't been previously installed
            return
        }
        
        let removeAppButton = springboard.buttons[Constants.removeApp]
        if removeAppButton.waitForExistence(timeout: timeout),
           removeAppButton.isHittable {
            removeAppButton.tap()
        } else {
            let deleteAppButton = appIcon.buttons[Constants.deleteButton]
            if deleteAppButton.waitForExistence(timeout: timeout) {
                deleteAppButton.tap()
            } else {
                XCTFail("Failed to find 'Remove App' and 'DeleteButton'")
            }
        }

        let deleteAppButton = springboard.alerts.buttons[Constants.deleteApp]
        if deleteAppButton.waitForExistence(timeout: timeout) {
            deleteAppButton.tap()
        } else {
            XCTFail("Failed to find 'Delete App'")
        }

        let finalDeleteButton = springboard.alerts.buttons[Constants.delete]
        if finalDeleteButton.waitForExistence(timeout: timeout) {
            finalDeleteButton.tap()
        } else {
            XCTFail("Failed to find 'Delete'")
        }
    }
}
