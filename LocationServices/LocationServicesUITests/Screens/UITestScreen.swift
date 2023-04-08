//
//  UITestScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import XCTest

protocol UITestScreen {
    var app: XCUIApplication { get }
}

fileprivate enum Identifiers {
    static var mapRendered: String { ViewsIdentifiers.General.mapRendered }
    static var mapHelper: String { ViewsIdentifiers.General.mapHelper }
}

extension UITestScreen {
    func getRenderedMap() -> XCUIElement {
        let map = app.otherElements.matching(identifier: Identifiers.mapRendered).element
        XCTAssertTrue(map.waitForExistence(timeout: UITestWaitTime.map.time))
        return map
    }
    
    func getMapHelper() -> XCUIElement {
        let view = app.otherElements.matching(identifier: Identifiers.mapHelper).element
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.regular.time))
        return view
    }
}

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        // workaround for apple bug
        if let placeholderString = self.placeholderValue, placeholderString == stringValue {
            return
        }

        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        
        typeText(deleteString)
    }
}
