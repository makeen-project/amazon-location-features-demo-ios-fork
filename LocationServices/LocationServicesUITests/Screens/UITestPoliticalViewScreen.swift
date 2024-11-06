//
//  UITestPoliticalViewScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

struct UITestPoliticalViewScreen: UITestScreen {
    let app: XCUIApplication
    
    private enum Identifiers {
        static var closeButton: String { ViewsIdentifiers.General.politicalViewCloseButton }
        static var politicalViewCell: String { ViewsIdentifiers.General.politicalViewCell }
        static var politicalViewTable: String { ViewsIdentifiers.General.politicalViewTable }
    }
    
    func select(politicalView: PoliticalViewType?) -> Self {
        let cell = getPoliticalViewCell(for: politicalView)
        cell.tap()
        
        return self
    }
    
    func tapCloseButton() -> UITestMapStyleScreen {
        let button = getCloseButton()
        button.tap()
        
        return UITestMapStyleScreen(app: app)
    }
    
    // MARK: - Private
    private func getPoliticalViewCell(for type: PoliticalViewType?, assert: Bool = true) -> XCUIElement {
        let cell = app.tables[Identifiers.politicalViewTable].cells.firstMatch
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

