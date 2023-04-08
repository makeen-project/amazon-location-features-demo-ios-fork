//
//  UITestMapStyleScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

struct UITestMapStyleScreen: UITestScreen {
    let app: XCUIApplication

    private enum Identifiers {
        static var closeButton: String { ViewsIdentifiers.General.closeButton }
    }
    
    func select(style: MapStyleImages) -> Self {
        let header = getSourceHeader(for: style.sourceType)
        header.tap()
        
        let cell = getStyleCell(for: style)
        cell.tap()
        
        return self
    }
    
    func tapCloseButton() -> UITestExploreScreen {
        let button = getCloseButton()
        button.tap()
        
        return UITestExploreScreen(app: app)
    }
    
    func isCellSelected(for style: MapStyleImages) -> Bool {
        let cell = getStyleCell(for: style, assert: false)
        return cell.exists && cell.isSelected
    }
    
    // MARK: - Private
    private func getSourceHeader(for sourceType: MapStyleSourceType) -> XCUIElement {
        let view = app.staticTexts[sourceType.title].firstMatch
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.regular.time))
        return view
    }
    
    private func getStyleCell(for style: MapStyleImages, assert: Bool = true) -> XCUIElement {
        let cell = app.cells[style.mapName].firstMatch
        if assert {
            XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.regular.time))
        } else {
            let _ = cell.waitForExistence(timeout: UITestWaitTime.regular.time)
        }
        return cell
    }
    
    private func getCloseButton() -> XCUIElement {
        let button = app.buttons[Identifiers.closeButton]
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
}
