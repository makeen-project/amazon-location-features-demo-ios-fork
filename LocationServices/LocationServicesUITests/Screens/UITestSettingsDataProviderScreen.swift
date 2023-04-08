//
//  UITestSettingsDataProviderScreen.swift
//  Amazon Location Demo UITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

struct UITestSettingsDataProviderScreen: UITestScreen {
    let app: XCUIApplication

    private enum Identifiers {
    }
    
    func select(sourceType: MapStyleSourceType) -> Self {
        let cell = getSourceTypeCell(for: sourceType)
        cell.tap()
        
        return self
    }
    
    func tapBackButton() -> UITestSettingsScreen {
        let button = getBackButton()
        button.tap()
        
        return UITestSettingsScreen(app: app)
    }
    
    func isCellSelected(for sourceType: MapStyleSourceType) -> Bool {
        let cell = getSourceTypeCell(for: sourceType)
        return cell.isSelected
    }
    
    // MARK: - Private
    private func getSourceTypeCell(for style: MapStyleSourceType) -> XCUIElement {
        let cell = app.cells[style.title].firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.regular.time))
        return cell
    }
    
    private func getBackButton() -> XCUIElement {
        return app.navigationBars.buttons.element(boundBy: 0)
    }
}
