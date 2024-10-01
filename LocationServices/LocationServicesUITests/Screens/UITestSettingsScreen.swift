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
        static var awsCloudCell: String { ViewsIdentifiers.Settings.awsCloudCell }
        static var dataProviderCell: String { ViewsIdentifiers.Settings.dataProviderCell }
        static var mapStyleCell: String { ViewsIdentifiers.Settings.mapStyleCell }
    }
    
    func waitRouteOptionsRow() -> Self {
        let _ = getRouteOptionCell()
        return self
    }
    
    func waitAWSCloudRow() -> Self {
        let _ = getAWSCloudCell()
        return self
    }
    
    func waittDataProviderRow() -> Self {
        let _ = getDataProviderCell()
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
    
    func tapConnectAWSRow() -> UITestAWSScreen {
        let cell = getAWSCloudCell()
        cell.tap()
        
        return UITestAWSScreen(app: app)
    }
    
    func tapMapStyleRow() -> UITestSettingsMapStyleScreen {
        let cell = getMapStyleCell()
        cell.tap()
        
        return UITestSettingsMapStyleScreen(app: app)
    }
    
    func tapDataProviderRow() -> UITestSettingsDataProviderScreen {
        let cell = getDataProviderCell()
        cell.tap()
        
        return UITestSettingsDataProviderScreen(app: app)
    }
    
    func getTabBarScreen() -> UITestTabBarScreen {
        return UITestTabBarScreen(app: app)
    }
    
    // MARK: - Private functions
    private func getRouteOptionCell() -> XCUIElement {
        let cell = app.cells[Identifiers.routeOptionCell]
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.regular.time))
        return cell
    }
    
    private func getAWSCloudCell() -> XCUIElement {
        print(app.cells.count)
        let cell = app.cells.element(boundBy: 3)
        print(cell.identifier)
        //let cell = app.cells[Identifiers.awsCloudCell]
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.regular.time))
        return cell
    }
    
    private func getDataProviderCell() -> XCUIElement {
        let cell = app.cells[Identifiers.dataProviderCell]
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.regular.time))
        return cell
    }
    
    private func getMapStyleCell() -> XCUIElement {
        let cell = app.cells[Identifiers.mapStyleCell]
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.regular.time))
        return cell
    }
    
}
