//
//  UITestSettingsMapStyleScreen.swift
//  Amazon Location Demo UITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

struct UITestSettingsMapStyleScreen: UITestScreen {
    let app: XCUIApplication

    private enum Identifiers {
    }
    
    func select(style: MapStyleImages) -> Self {
        let cell = getStyleCell(for: style)
        cell.tap()
        
        return self
    }
    
    func tapBackButton() -> UITestSettingsScreen {
        guard UIDevice.current.userInterfaceIdiom == .phone else {
            return  UITestSettingsScreen(app: app)
        }
        let button = getBackButton()
        button.tap()
        
        return UITestSettingsScreen(app: app)
    }
    
    func isCellSelected(for style: MapStyleImages) -> Bool {
        let cell = getStyleCell(for: style)
        return cell.isSelected
    }
    
    // MARK: - Private
    private func getStyleCell(for style: MapStyleImages) -> XCUIElement {
        let cell = app.cells[style.mapName].firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.regular.time))
        return cell
    }
    
    private func getBackButton() -> XCUIElement {
        return app.navigationBars.buttons.element(boundBy: 0)
    }
}
