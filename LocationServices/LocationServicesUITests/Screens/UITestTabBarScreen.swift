//
//  UITestTabBarScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

struct UITestTabBarScreen: UITestScreen {
    let app: XCUIApplication
    
    private enum Identifiers {
        static var exploreTabBarButton: String { ViewsIdentifiers.General.exploreTabBarButton }
        static var settingsTabBarButton: String { ViewsIdentifiers.General.settingsTabBarButton }
        static var trackingTabBarButton: String { ViewsIdentifiers.General.trackingTabBarButton }
        static var geofenceTabBarButton: String { ViewsIdentifiers.General.geofenceTabBarButton }
    }
    
    func tapExploreButton() -> UITestExploreScreen {
        let button = getExploreTabBarButton()
        button.tap()
        
        return UITestExploreScreen(app: app)
    }
    
    func tapSettingsButton() -> UITestSettingsScreen {
        let settingsButton = getSettingsTabBarButton()
        settingsButton.tap()
        
        return UITestSettingsScreen(app: app)
    }
    
    func tapTrackingButton() -> UITestTrackingScreen {
        let trackingButton = getTrackingTabBarButton()
        trackingButton.tap()
        
        return UITestTrackingScreen(app: app)
    }
    
    func tapGeofenceButton() -> UITestGeofenceScreen {
        let settingsButton = getGeofenceTabBarButton()
        settingsButton.tap()
        
        return UITestGeofenceScreen(app: app)
    }
    
    // MARK: - Private functions
    private func getExploreTabBarButton() -> XCUIElement {
        let button = app.tabBars.buttons[Identifiers.exploreTabBarButton]
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
    
    private func getSettingsTabBarButton() -> XCUIElement {
        let settingsButton = app.tabBars.buttons[Identifiers.settingsTabBarButton]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: UITestWaitTime.long.time))
        return settingsButton
    }
    
    private func getTrackingTabBarButton() -> XCUIElement {
        let trackingButton = app.tabBars.buttons[Identifiers.trackingTabBarButton]
        XCTAssertTrue(trackingButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        return trackingButton
    }

    private func getGeofenceTabBarButton() -> XCUIElement {
        let geofenceButton = app.tabBars.buttons[Identifiers.geofenceTabBarButton]
        XCTAssertTrue(geofenceButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        return geofenceButton
    }
}

