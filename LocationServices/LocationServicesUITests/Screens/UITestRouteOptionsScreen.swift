//
//  UITestRouteOptionsScreen.swift
//  Amazon Location Demo UITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

struct UITestRouteOptionsScreen: UITestScreen {
    let app: XCUIApplication
    
    private enum Identifiers {
        static var avoidTollsOptionContainer: String { ViewsIdentifiers.Routing.avoidTollsOptionContainer }
        static var avoidFerriesOptionContainer: String { ViewsIdentifiers.Routing.avoidFerriesOptionContainer }
        static var routeOptionSwitchButton: String { ViewsIdentifiers.Routing.routeOptionSwitchButton }
    }
    
    func waitForAvoidTollsContainer() -> Self {
        let _ = getAvoidTollsContainer()
        return self
    }
    
    func waitForAvoidFerriesContainer() -> Self {
        let _ = getAvoidFerriesContainer()
        return self
    }
    
    func switchAvoidTolls() -> Self {
        let container = getAvoidTollsContainer()
        let switchButton = getSwitchButtonForOptionContainer(container)
        switchButton.tap()
        
        return self
    }
    
    func switchAvoidFerries() -> Self {
        let container = getAvoidFerriesContainer()
        let switchButton = getSwitchButtonForOptionContainer(container)
        switchButton.tap()
        
        return self
    }
    
    func tapBackButton() -> UITestSettingsScreen {
        let button = getBackButton()
        button.tap()
        
        return UITestSettingsScreen(app: app)
    }
    
    func isOnAvoidTollsSwitch() -> Bool {
        let container = getAvoidTollsContainer()
        let switchButton = getSwitchButtonForOptionContainer(container)
        
        return Int((switchButton.value as? String) ?? "") == 1
    }
    
    func isOnAvoidFerriesSwitch() -> Bool {
        let container = getAvoidFerriesContainer()
        let switchButton = getSwitchButtonForOptionContainer(container)
        
        return Int((switchButton.value as? String) ?? "") == 1
    }
    
    // MARK: - Private functions
    private func getAvoidTollsContainer() -> XCUIElement {
        let view = app.otherElements[Identifiers.avoidTollsOptionContainer].firstMatch
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.regular.time))
        return view
    }
    
    private func getAvoidFerriesContainer() -> XCUIElement {
        let view = app.otherElements[Identifiers.avoidFerriesOptionContainer].firstMatch
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.regular.time))
        return view
    }
    
    private func getSwitchButtonForOptionContainer(_ container: XCUIElement) -> XCUIElement {
        let switcher = container.switches[Identifiers.routeOptionSwitchButton].firstMatch
        XCTAssertTrue(switcher.waitForExistence(timeout: UITestWaitTime.regular.time))
        return switcher
    }
    
    private func getBackButton() -> XCUIElement {
        return app.navigationBars.buttons.element(boundBy: 0)
    }
}
