//
//  UITestRoutingScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

struct UITestRoutingScreen: UITestScreen {
    let app: XCUIApplication

    private enum Identifiers {
        static var departureTextField: String { ViewsIdentifiers.Routing.departureTextField }
        static var destinationTextField: String { ViewsIdentifiers.Routing.destinationTextField }
        static var swapButton: String { ViewsIdentifiers.Routing.swapButton }
        static var routeTypesContainer: String { ViewsIdentifiers.Routing.routeTypesContainer }
        static var navigateButton: String { ViewsIdentifiers.Routing.navigateButton }
        static var cellAddressLabel: String { ViewsIdentifiers.Search.cellAddressLabel }
        static var routeOptionsVisibilityButton: String { ViewsIdentifiers.Routing.routeOptionsVisibilityButton }
        static var avoidTollsOptionContainer: String { ViewsIdentifiers.Routing.avoidTollsOptionContainer }
        static var avoidFerriesOptionContainer: String { ViewsIdentifiers.Routing.avoidFerriesOptionContainer }
        static var routeOptionSwitchButton: String { ViewsIdentifiers.Routing.routeOptionSwitchButton }
        static var routeEstimatedTime: String { ViewsIdentifiers.Routing.routeEstimatedTime }
        static var routeEstimatedDistance: String { ViewsIdentifiers.Routing.routeEstimatedDistance }
        static var imageAnnotationView: String { ViewsIdentifiers.General.imageAnnotationView }
        static var tableView: String { ViewsIdentifiers.Routing.tableView }
    }
    
    func selectDepartureTextField() -> Self {
        let textField = getDepartureTextField()
        textField.tap()
        clearText(textField: textField)
        return self
    }

    func selectDestinationTextField() -> Self {
        let textField = getDestinationTextField()
        textField.tap()

        return self
    }
    
    func typeInDepartureTextField(text: String) -> Self {
        let textField = getDepartureTextField()
        textField.tap()
        clearText(textField: textField)
        textField.typeText(text)
        
        return self
    }
    
    func clearText(textField: XCUIElement){
        if(textField.buttons["Clear text"].exists) {
            textField.buttons["Clear text"].tap()
        }
    }
    
    func typeInDestinationTextField(text: String) -> Self {
        let textField = getDestinationTextField()
        textField.tap()
        clearText(textField: textField)
        textField.typeText(text)
        
        return self
    }
    
    func swapRoute() -> Self {
        let button = getSwapButton()
        button.tap()
        
        return self
    }
    
    func waitForResultsInTable(minimumCount: Int? = nil) -> Self {
        Thread.sleep(forTimeInterval: 10)
        let cell = getTable().cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.request.time))

        if let minimumCount {
            XCTAssertGreaterThanOrEqual(getTable().cells.count, minimumCount)
        }

        return self
    }
    
    func selectSearchResult(index :Int) -> Self {
        Thread.sleep(forTimeInterval: 10)
        //let predicate = NSPredicate(format: "label != %@ && label != ''", "My Location")
        let cell = getTable().cells.element(boundBy: index)
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.request.time))
        cell.tap()
        return self
    }
    
    func waitForRouteTypesContainer() -> Self {
        Thread.sleep(forTimeInterval: 2)
        let _ = getRouteTypesContainer()
        return self
    }
    
    func waitForRouteTypeContainer(_ mode: RouteType) -> Self {
        let _ = getRouteContainer(mode: mode)
        return self
    }
    
    func waitForNonEmptyRouteEstimatedTime(for mode: RouteType) -> Self {
        let container = getRouteContainer(mode: mode)
        let label = getEstimatedTimeLabel(for: container)
        XCTAssertNotEqual(label.label, "")
        return self
    }
    
    func waitForNonEmptyRouteEstimatedDistance(for mode: RouteType) -> Self {
        let container = getRouteContainer(mode: mode)
        let label = getEstimatedDistanceLabel(for: container)
        XCTAssertNotEqual(label.label, "")
        return self
    }
    
    func waitForMapToBeRendered() -> Self {
        let _ = getRenderedMap()
        return self
    }
    
    func validateMapIsAdjustedToTheRoute() -> Self {
        //wait for existence
        let _ = getPoiCircle()
        let poiCircles = app.buttons.matching(identifier: Identifiers.imageAnnotationView)
        let countOfAnnotationsForRoute = 2
        XCTAssertEqual(poiCircles.count, countOfAnnotationsForRoute)
        for index in 0..<poiCircles.count {
            let poiCircle = poiCircles.element(boundBy: index)
            XCTAssertTrue(poiCircle.isHittable)
        }
        
        return self
    }
    
    func switchRouteOptionsVisibility() -> Self {
        let button = getRouteOptionsVisibilityButton()
        button.tap()
        
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
    
    func activate(mode: RouteType) -> UITestNavigationScreen {
        let container = getRouteContainer(mode: mode)
        let button = container.buttons[Identifiers.navigateButton]
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        button.tap()
        
        return UITestNavigationScreen(app: app)
    }
    
    func getCellsInfo() -> [String] {
        let cells = getTable().cells
        let cellsCount = cells.count
        
        var titles: [String] = []
        for index in 0..<cellsCount {
            let cell = cells.element(boundBy: index)
            let addressLabel = cell.staticTexts[Identifiers.cellAddressLabel]
            if(addressLabel.exists){
                titles.append(addressLabel.label)
            }
        }
        
        return titles
    }
    
    func getDeparturePlace() -> String? {
        let textField = getDepartureTextField()
        return textField.value as? String
    }
    
    func getDestinationPlace() -> String? {
        let textField = getDestinationTextField()
        return textField.value as? String
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
    
    func getMapScreenshot() -> XCUIScreenshot {
        let _ = getRenderedMap()
        let mapHelper = getMapHelper()
        return mapHelper.screenshot()
    }
    
    // MARK: - Private
    private func getDepartureTextField() -> XCUIElement {
        let textField = app.textFields[Identifiers.departureTextField]
        XCTAssertTrue(textField.waitForExistence(timeout: UITestWaitTime.regular.time))
        return textField
    }
    
    private func getDestinationTextField() -> XCUIElement {
        let textField = app.textFields[Identifiers.destinationTextField]
        XCTAssertTrue(textField.waitForExistence(timeout: UITestWaitTime.regular.time))
        return textField
    }
    
    private func getSwapButton() -> XCUIElement {
        let button = app.buttons[Identifiers.swapButton]
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
    
    private func getRouteTypesContainer() -> XCUIElement {
        let view = app.otherElements[Identifiers.routeTypesContainer]
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.request.time))
        return view
    }
    
    private func getRouteContainer(mode: RouteType) -> XCUIElement {
        let view = app.otherElements[mode.containerId]
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.regular.time))
        return view
    }
    
    private func getEstimatedTimeLabel(for container: XCUIElement) -> XCUIElement {
        let label = container.staticTexts[Identifiers.routeEstimatedTime].firstMatch
        XCTAssertTrue(label.waitForExistence(timeout: UITestWaitTime.regular.time))
        return label
    }
    
    private func getEstimatedDistanceLabel(for container: XCUIElement) -> XCUIElement {
        let label = container.staticTexts[Identifiers.routeEstimatedDistance].firstMatch
        XCTAssertTrue(label.waitForExistence(timeout: UITestWaitTime.regular.time))
        return label
    }
    
    private func getRouteOptionsVisibilityButton() -> XCUIElement {
        let view = app.buttons[Identifiers.routeOptionsVisibilityButton]
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.regular.time))
        return view
    }
    
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
    
    private func getPoiCircle() -> XCUIElement {
        let button = app.buttons[Identifiers.imageAnnotationView]
        XCTAssertTrue(button.waitForExistence(timeout: UITestWaitTime.regular.time))
        return button
    }
    
    private func getTable() -> XCUIElement {
        return app.tables[Identifiers.tableView]
    }
}

