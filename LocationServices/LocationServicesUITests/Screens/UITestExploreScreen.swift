//
//  UITestExploreScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

struct UITestExploreScreen: UITestScreen {
    let app: XCUIApplication

    private enum Identifiers {
        static var userLocationAnnotation: String { ViewsIdentifiers.General.userLocationAnnotation }
        static var locateMeButton: String { ViewsIdentifiers.General.locateMeButton }
        static var exploreView: String { ViewsIdentifiers.Explore.exploreView }
        static var searchBar: String {  ViewsIdentifiers.Search.searchBar }
        static var searchTextField: String { ViewsIdentifiers.Search.searchTextField }

        static var mapStyles: String { ViewsIdentifiers.General.mapStyles }
        static var routingButton: String { ViewsIdentifiers.General.routingButton }
    }

    func waitForMapToBeRendered() -> Self {
        let _ = getRenderedMap()
        return self
    }
    
    func zoomInWithPinch(scale: CGFloat = 3) -> Self {
        let screenshotBefore = getRenderedMap().screenshot()
        getRenderedMap().pinch(withScale: scale, velocity: 1)
        let screenshotAfter = getRenderedMap().screenshot()
        
        XCTAssertNotEqual(screenshotBefore.pngRepresentation, screenshotAfter.pngRepresentation)
        
        return self
    }
    
    func zoomInToMax() -> Self {
        var zoomLevelBefore = getMapZoomLevel()
        var zoomLevelAfter = zoomLevelBefore
        
        repeat {
            zoomLevelBefore = getMapZoomLevel()
            getRenderedMap().pinch(withScale: 3, velocity: 1)
            zoomLevelAfter = getMapZoomLevel()
        } while zoomLevelBefore != zoomLevelAfter
        
        return self
    }
    
    func zoomInWithPinchFails() -> Self {
        let zoomLevelBefore = getMapZoomLevel()
        getRenderedMap().pinch(withScale: 2, velocity: 1)
        let zoomLevelAfter = getMapZoomLevel()
        
        XCTAssertEqual(zoomLevelBefore, zoomLevelAfter)
        
        return self
    }
    
    func zoomInWithTap() -> Self {
        let screenshotBefore = getRenderedMap().screenshot()
        getRenderedMap().doubleTap()
        let screenshotAfter = getRenderedMap().screenshot()
        
        XCTAssertNotEqual(screenshotBefore.pngRepresentation, screenshotAfter.pngRepresentation)
        
        return self
    }
    
    func zoomOut() -> Self {
        let screenshotBefore = getRenderedMap().screenshot()
        getMapHelper().pinch(withScale: 0.5, velocity: -1)
        let screenshotAfter = getRenderedMap().screenshot()
        
        XCTAssertNotEqual(screenshotBefore.pngRepresentation, screenshotAfter.pngRepresentation)
        
        return self
    }
    
    func zoomOutToMax() -> Self {
        var zoomLevelBefore = getMapZoomLevel()
        var zoomLevelAfter = zoomLevelBefore
        
        repeat {
            zoomLevelBefore = getMapZoomLevel()
            getMapHelper().pinch(withScale: 3, velocity: 1)
            zoomLevelAfter = getMapZoomLevel()
        } while zoomLevelBefore != zoomLevelAfter
        
        return self
    }
    
    func zoomOutFails() -> Self {
        let zoomLevelBefore = getMapZoomLevel()
        getMapHelper().pinch(withScale: 2, velocity: 1)
        let zoomLevelAfter = getMapZoomLevel()
        
        XCTAssertEqual(zoomLevelBefore, zoomLevelAfter)
        
        return self
    }
    
    func waitForUserLocationAnnotation() -> Self {
        let userLocationAnnotation = app.buttons.matching(identifier: Identifiers.userLocationAnnotation).element
        
        XCTAssertTrue(userLocationAnnotation.waitForExistence(timeout: UITestWaitTime.regular.time))
        XCTAssertTrue(userLocationAnnotation.isHittable)
        
        return self
    }
    
    func checkAbsenceOfUserLocationAnnotation() -> Self {
        let userLocationAnnotation = app.buttons.matching(identifier: Identifiers.userLocationAnnotation).element
        
        let existed = userLocationAnnotation.waitForExistence(timeout: UITestWaitTime.regular.time)
        if existed {
            XCTAssertFalse(userLocationAnnotation.isHittable)
        } else {
            XCTAssertFalse(existed)
        }
        
        return self
    }
    
    func swipeMap(direction: UITestSwipeDirection, repeats: Int = 1) -> Self {
        let map = getRenderedMap()
        
        for _ in 0..<1 {
            switch direction {
            case .left:
                map.swipeLeft()
            case .right:
                map.swipeRight()
            case .up:
                map.swipeUp()
            case .down:
                map.swipeDown()
            }
        }
        
        return self
    }
    
    func tapLocateMeButton() -> Self {
        let locateMeButton = app.buttons.matching(identifier: Identifiers.locateMeButton).element
        XCTAssertTrue(locateMeButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        locateMeButton.tap()
        return self
    }
    
    func waitForSeachBarToBeRendered() -> Self {
        let _ = getSearchBar()
        return self
    }
    
    func checkSearchBarInCorrectPosition() -> Self {
        let searchBox = getSearchBar()
        let exploreView = getExploreView()
        
        XCTAssertEqual(exploreView.frame.width, searchBox.frame.width)
        XCTAssertEqual(exploreView.frame.width / 2, searchBox.frame.midX)
        XCTAssertEqual(exploreView.frame.height, searchBox.frame.maxY)
        
        return self
    }
    
    func tapSearchTextField() -> UITestSearchScreen {
        let searchTextField = getSearchTextField()
        searchTextField.tap()
        
        return UITestSearchScreen(app: app)
    }
    
    func tapMapStyles() -> UITestMapStyleScreen {
        let button = getMapStyleButton()
        button.tap()
        
        return UITestMapStyleScreen(app: app)
    }
    
    func tapRouting() -> UITestRoutingScreen {
        let button = getRoutingButton()
        button.tap()
        
        return UITestRoutingScreen(app: app)
    }
    
    func getTabBarScreen() -> UITestTabBarScreen {
        return UITestTabBarScreen(app: app)
    }
    
    func takeMapScreenshot() -> XCUIScreenshot {
        return getRenderedMap().screenshot()
    }
    
    // MARK: - Private functions
    private func getExploreView() -> XCUIElement {
        let exploreView = app.otherElements.matching(identifier: Identifiers.exploreView).element
        XCTAssertTrue(exploreView.waitForExistence(timeout: UITestWaitTime.regular.time))
        
        return exploreView
    } 
    
    private func getSearchBar() -> XCUIElement {
        let searchBar = app.otherElements[Identifiers.searchBar].firstMatch
        XCTAssertTrue(searchBar.waitForExistence(timeout: UITestWaitTime.regular.time))
        return searchBar
    }
    
    private func getSearchTextField() -> XCUIElement {
        let searchBar = app.textFields[Identifiers.searchTextField]
        XCTAssertTrue(searchBar.waitForExistence(timeout: UITestWaitTime.regular.time))
        return searchBar
    }

    private func getMapStyleButton() -> XCUIElement {
        let button = app.buttons[Identifiers.mapStyles]
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
    
    private func getRoutingButton() -> XCUIElement {
        let button = app.buttons[Identifiers.routingButton]
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
    
    private func getMapZoomLevel() -> String {
        let value = getRenderedMap().value as? String
        return value ?? ""
    }
}
