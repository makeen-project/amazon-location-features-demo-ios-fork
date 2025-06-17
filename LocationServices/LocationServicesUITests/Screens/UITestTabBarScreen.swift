//
//  UITestTabBarScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

struct UITestTabBarScreen: UITestScreen {
    
    //this properties are displaying the state of SplitViewController in the app
    //and should be changed if the state change was triggered outside of sidebar
    //This properties are used only for iPad
    static var isPrimaryViewVisible: Bool = false
    static var isSupplementaryViewVisible: Bool = false
    
    let app: XCUIApplication
    
    private enum Identifiers {
        static var exploreTabBarButton: String { ViewsIdentifiers.General.exploreTabBarButton }
        static var settingsTabBarButton: String { ViewsIdentifiers.General.settingsTabBarButton }
        static var trackingTabBarButton: String { ViewsIdentifiers.General.trackingTabBarButton }
        static var aboutTabBarButton: String { ViewsIdentifiers.General.aboutTabBarButton }
        static var sideBarButton: String { ViewsIdentifiers.General.sideBarButton }
        static var fullScreenButton: String { ViewsIdentifiers.General.fullScreenButton }
        static var sideBarTableView: String { ViewsIdentifiers.General.sideBarTableView }
    }
    
    static func resetSideBarState() {
        isPrimaryViewVisible = false
        isSupplementaryViewVisible = false
    }
    
    func tapExploreButton() -> UITestExploreScreen {
        showSideBar()
        let button = getExploreTabBarButton()
        button.tap()
        
        return UITestExploreScreen(app: app)
    }
    
    func tapSettingsButton() -> UITestSettingsScreen {
        showSideBar()
        let settingsButton = getSettingsTabBarButton()
        settingsButton.tap()
        return UITestSettingsScreen(app: app)
    }
    
    func tapTrackingButton() -> UITestTrackingScreen {
        showSideBar()
        let trackingButton = getTrackingTabBarButton()
        trackingButton.tap()
        
        return UITestTrackingScreen(app: app)
    }
    
    func tapAboutButton() -> UITestExploreScreen {
        showSideBar()
        let button = getAboutTabBarButton()
        button.tap()
        
        return UITestExploreScreen(app: app)
    }
    
    func showFullScreen() {
        let button = getFullScreenButton()
        button.tap()
    }
    
    // MARK: - Private functions
    private func getExploreTabBarButton() -> XCUIElement {
        let button = getBarItem(identifier: Identifiers.exploreTabBarButton)
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
    
    private func getSettingsTabBarButton() -> XCUIElement {
        let button = getBarItem(identifier: Identifiers.settingsTabBarButton)
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.long.time))
        return button
    }
    
    private func getTrackingTabBarButton() -> XCUIElement {
        let button = getBarItem(identifier: Identifiers.trackingTabBarButton)
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
    
    private func getAboutTabBarButton() -> XCUIElement {
        let button = getBarItem(identifier: Identifiers.aboutTabBarButton)
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
    
    private func getBarItem(identifier: String) -> XCUIElement {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let table = app.tables[Identifiers.sideBarTableView]
            XCTAssertTrue(table.waitForExistence(timeout: UITestWaitTime.regular.time))
            return table.cells[identifier]
        } else {
            return app.tabBars.buttons[identifier]
        }
    }
    
    //MARK: - SideBar
    private func showSideBar() {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return }
        
        if !Self.isSupplementaryViewVisible {
            tapSideBarButton()
            Self.isSupplementaryViewVisible = true
        }
        
        if !Self.isPrimaryViewVisible {
            tapSideBarButton()
            Self.isPrimaryViewVisible = true
        }
    }
    
    private func tapSideBarButton() {
        let button = getSideBarButton()
        button.tap()
    }
    
    private func getSideBarButton() -> XCUIElement {
        let button = app.buttons[Identifiers.sideBarButton]
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
    
    private func getFullScreenButton() -> XCUIElement {
        let button = app.buttons[Identifiers.fullScreenButton]
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
}

