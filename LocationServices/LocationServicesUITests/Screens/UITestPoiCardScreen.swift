//
//  UITestPoiCardScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

struct UITestPoiCardScreen: UITestScreen {
    let app: XCUIApplication

    private enum Identifiers {
        static var poiCardView: String { ViewsIdentifiers.PoiCard.poiCardView }
        static var travelTimeLabel: String { ViewsIdentifiers.PoiCard.travelTimeLabel }
        static var directionButton: String { ViewsIdentifiers.PoiCard.directionButton }
        static var imageAnnotationView: String { ViewsIdentifiers.General.imageAnnotationView }
    }
    
    func waitForPoiCardView() -> Self {
        let _ = getRootView()
        return self
    }
    
    func waitForTravelTimeLabel() -> Self {
        let _ = getTravelTimeLabel()
        return self
    }
    
    func waitForDirectionButton() -> Self {
        let _ = getDirectionButton()
        return self
    }
    
    func waitForPoiCicle() -> Self {
        let _ = getPoiCircle()
        return self
    }
    
    func tapDirectionButton() -> UITestRoutingScreen {
        let directionButton = getDirectionButton()
        directionButton.tap()
        
        return UITestRoutingScreen(app: app)
    }
    
    // MARK: - Private
    private func getRootView() -> XCUIElement {
        let view = app.otherElements[Identifiers.poiCardView].firstMatch
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.navigation.time))
        return view
    }
    
    private func getTravelTimeLabel() -> XCUIElement {
        let view = app.staticTexts[Identifiers.travelTimeLabel].firstMatch
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.regular.time))
        return view
    }
    
    private func getDirectionButton() -> XCUIElement {
        let button = app.buttons[Identifiers.directionButton]
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
    
    private func getPoiCircle() -> XCUIElement {
        let button = app.buttons[Identifiers.imageAnnotationView]
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
}
