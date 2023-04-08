//
//  UITestSearchScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

struct UITestSearchScreen: UITestScreen {
    let app: XCUIApplication
    
    private enum Identifiers {
        static var searchRootView: String { ViewsIdentifiers.Search.searchRootView }
        static var searchBar: String { ViewsIdentifiers.Search.searchBar }
        static var searchTextField: String { ViewsIdentifiers.Search.searchTextField }
        static var noResults: String { ViewsIdentifiers.Search.noResultsView }
        static var cellAddressLabel: String { ViewsIdentifiers.Search.cellAddressLabel }
        static var imageAnnotationView: String { ViewsIdentifiers.General.imageAnnotationView }
    }
    
    func type(text: String) -> Self {
        let searchBar = getSearchBar()
        searchBar.typeText(text)
        
        return self
    }
    
    func tapKeyboardReturnButton() -> Self {
        let keyboardReturnButton = app.keyboards.element.buttons["return"]
        XCTAssertTrue(keyboardReturnButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        keyboardReturnButton.tap()
        
        return self
    }
    
    func tapFirstCell() -> UITestPoiCardScreen {
        let cell = app.tables.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.request.time))
        cell.tap()
        
        return UITestPoiCardScreen(app: app)
    }
    
    func waitForResultsInTable(minimumCount: Int? = nil) -> Self {
        let cell = app.tables.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.request.time))
        
        if let minimumCount {
            XCTAssertGreaterThanOrEqual(app.tables.cells.count, minimumCount)
        }
        
        return self
    }
    
    func validateResultsOnMap() -> Self {
        let cellsCount = app.tables.cells.count
        let annotationsCount = getPoiCirclesCount()
        XCTAssertEqual(cellsCount, annotationsCount)
        return self
    }
    
    func hasAddressInFirstCell() -> Self {
        let cell = app.tables.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.request.time))
        
        let addressLabel = cell.staticTexts[Identifiers.cellAddressLabel]
        XCTAssertTrue(addressLabel.waitForExistence(timeout: UITestWaitTime.regular.time))
        
        return self
    }
    
    func lightSwipeDownStateShouldBeChanged() -> Self {
        let view = getSearchRootView()
        
        let heightBefore = view.frame.height
        
        let start = view.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let end = view.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0.4))
        start.press(forDuration: 0.5, thenDragTo: end)
        
        if view.exists {
            let heightAfter = view.frame.height
            XCTAssertNotEqual(heightBefore, heightAfter)
        }
        
        return self
    }
    
    func waitForSearchRootView() -> Self {
        let _ = getSearchRootView()
        return self
    }
    
    func screenShouldBeClosed() -> UITestExploreScreen {
        let view = app.otherElements[Identifiers.searchRootView].firstMatch
        XCTAssertFalse(view.waitForExistence(timeout: UITestWaitTime.regular.time))
        
        return UITestExploreScreen(app: app)
    }
    
    func waitForNoResultsView() -> Self {
        let noResultsView = app.otherElements[Identifiers.noResults].firstMatch
        XCTAssertTrue(noResultsView.waitForExistence(timeout: UITestWaitTime.request.time))
        
        return self
    }
    
    func close() -> UITestExploreScreen {
        let view = getSearchRootView()

        let start = view.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let end = view.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 1))
        start.press(forDuration: 0.5, thenDragTo: end)
        
        return UITestExploreScreen(app: app)
    }
    
    func getCellsInfo() -> [String] {
        let cells = app.tables.cells
        let cellsCount = cells.count
        
        var titles: [String] = []
        for index in 0..<cellsCount {
            let cell = cells.element(boundBy: index)
            let addressLabel = cell.staticTexts[Identifiers.cellAddressLabel]
            titles.append(addressLabel.label)
        }
        
        return titles
    }
    
    // MARK: - Private
    private func getSearchRootView() -> XCUIElement {
        let view = app.otherElements[Identifiers.searchRootView].firstMatch
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.regular.time))
        return view
    }
    
    private func getSearchBar() -> XCUIElement {
        let searchBar = app.textFields[Identifiers.searchTextField]
        XCTAssertTrue(searchBar.waitForExistence(timeout: UITestWaitTime.regular.time))
        return searchBar
    }
    
    private func getPoiCircle() -> XCUIElement {
        let button = app.buttons[Identifiers.imageAnnotationView]
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
    
    private func getPoiCirclesCount() -> Int {
        //wait for existence
        let _ = getPoiCircle()
        return app.buttons.matching(identifier: Identifiers.imageAnnotationView).count
    }
}
