//
//  UITestNavigationScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

struct UITestNavigationScreen: UITestScreen {
    let app: XCUIApplication

    private enum Identifiers {
        static var rootView: String { ViewsIdentifiers.Navigation.navigationRootView }
        static var navigationExitButton: String { ViewsIdentifiers.Navigation.navigationExitButton }
    }
    
    func waitForRootView() -> Self {
        let _ = getRootView()
        return self
    }
    
    func tapExitButton() -> UITestRoutingScreen {
        let button = getExitButton()
        button.tap()
        
        return UITestRoutingScreen(app: app)
    }
    
    func getCellsCount() -> Int {
        return app.cells.count
    }
    
    // MARK: - Private
    private func getRootView() -> XCUIElement {
        let view = app.otherElements[Identifiers.rootView].firstMatch
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.regular.time))
        return view
    }
    
    private func getExitButton() -> XCUIElement {
        let view = app.buttons[Identifiers.navigationExitButton].firstMatch
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.regular.time))
        return view
    }
}
