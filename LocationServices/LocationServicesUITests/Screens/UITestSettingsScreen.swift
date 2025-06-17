//
//  UITestAWSScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

struct UITestSettingsScreen: UITestScreen {
    let app: XCUIApplication
    
    private enum Identifiers {
        static var routeOptionCell: String { ViewsIdentifiers.Settings.routeOptionCell }
        static var dataProviderCell: String { ViewsIdentifiers.Settings.dataProviderCell }
        static var mapStyleCell: String { ViewsIdentifiers.Settings.mapStyleCell }
    }
    
    func waitRouteOptionsRow() -> Self {
        let _ = getRouteOptionCell()
        return self
    }
    
    func waitMapStyleRow() -> Self {
        let _ = getMapStyleCell()
        return self
    }
    
    func tapRouteOptionsRow() -> UITestRouteOptionsScreen {
        let cell = getRouteOptionCell()
        cell.tap()
        
        return UITestRouteOptionsScreen(app: app)
    }
    
    func tapMapStyleRow() -> UITestSettingsMapStyleScreen {
        let cell = getMapStyleCell()
        cell.tap()
        
        return UITestSettingsMapStyleScreen(app: app)
    }
    
    func getTabBarScreen() -> UITestTabBarScreen {
        return UITestTabBarScreen(app: app)
    }
    
    // MARK: - Private functions
    private func getRouteOptionCell() -> XCUIElement {
        app.activate()
        let cell = app.cells[Identifiers.routeOptionCell]
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.regular.time))
        return cell
    }
    
    private func getMapStyleCell() -> XCUIElement {
        app.activate()
        let cell = app.cells[Identifiers.mapStyleCell]
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.regular.time))
        return cell
    }
    
}
