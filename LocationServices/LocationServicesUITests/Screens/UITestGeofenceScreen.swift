//
//  UITestTrackingScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

import XCTest

struct UITestGeofenceScreen: UITestScreen {
    let app: XCUIApplication
    
    private enum Identifiers {
        static var awsConnectTitleLabel: String { ViewsIdentifiers.AWSConnect.awsConnectTitleLabel }
        static var addGeofenceButton: String { ViewsIdentifiers.Geofence.addGeofenceButton }
        static var addGeofenceButtonEmptyList: String { ViewsIdentifiers.Geofence.addGeofenceButtonEmptyList }
        static var geofenceTableView: String { ViewsIdentifiers.Geofence.geofenceTableView }
        static var deleteGeofenceButton: String { ViewsIdentifiers.Geofence.deleteGeofenceButton }
        static var geofenceNameTextField: String { ViewsIdentifiers.Geofence.geofenceNameTextField }
        static var saveGeofenceButton: String { ViewsIdentifiers.Geofence.saveGeofenceButton }
        static var searchGeofenceTextField: String { ViewsIdentifiers.Geofence.searchGeofenceTextField }
        static var radiusGeofenceSliderField: String { ViewsIdentifiers.Geofence.radiusGeofenceSliderField }
        static var addGeofenceTableView: String { ViewsIdentifiers.Geofence.addGeofenceTableView }
    }
    
    func waitForAWSConnectionScreen() -> UITestAWSScreen {
        let label = app.otherElements[Identifiers.awsConnectTitleLabel].firstMatch
        XCTAssertFalse(label.waitForExistence(timeout: UITestWaitTime.regular.time))
        
        return UITestAWSScreen(app: app)
    }
    
    func tapAddGeofenceButton() -> UITestGeofenceScreen {
      let addGeofenceButton = app.buttons.matching(identifier: Identifiers.addGeofenceButton).element
        
        if !addGeofenceButton.waitForExistence(timeout: UITestWaitTime.regular.time) {
            let addGeofenceButtonEmptyList = app.buttons.matching(identifier: Identifiers.addGeofenceButtonEmptyList).element
            XCTAssertTrue(addGeofenceButtonEmptyList.waitForExistence(timeout: UITestWaitTime.long.time))
            addGeofenceButtonEmptyList.tap()
        }
        
        XCTAssertTrue(addGeofenceButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        addGeofenceButton.tap()
        return self
    }
    
    func selectGeofenceLocation(location: String, matchCellText: String? = nil) -> UITestGeofenceScreen {
        let searchBar = app.textFields[Identifiers.searchGeofenceTextField]
        XCTAssertTrue(searchBar.waitForExistence(timeout: UITestWaitTime.regular.time))
        
        searchBar.tap()
        searchBar.buttons["Clear text"].tap()
        searchBar.typeText(location)
        sleep(3)
        var cell = getAddGeofenceTable().firstMatch
        if(matchCellText != nil){
            cell = getAddGeofenceTable().cells.containing(.staticText, identifier: matchCellText).element
        }
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.request.time))
        cell.tap()
        
        return self
    }
    
    func typeGeofenceName(geofenceName: String) -> UITestGeofenceScreen {
        let geofenceTextField = app.textFields[Identifiers.geofenceNameTextField]
        XCTAssertTrue(geofenceTextField.waitForExistence(timeout: UITestWaitTime.regular.time))
        
        geofenceTextField.tap()
        geofenceTextField.typeText(geofenceName)
        return self
    }
    
    func setGeofenceRadius() -> UITestGeofenceScreen {
        let radiusGeofenceSliderField = app.sliders[Identifiers.radiusGeofenceSliderField]
        XCTAssertTrue(radiusGeofenceSliderField.waitForExistence(timeout: UITestWaitTime.regular.time))
        
        let radius = Double.random(in: 0..<1)
        radiusGeofenceSliderField.adjust(toNormalizedSliderPosition: radius)

        return self
    }
    
    func tapSaveButton() -> UITestGeofenceScreen {
        let saveGeofenceButton = app.buttons.matching(identifier: Identifiers.saveGeofenceButton).element
          XCTAssertTrue(saveGeofenceButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        saveGeofenceButton.tap()
          return self
    }
    
    func verifyGeofenceByName(geofenceName: String) -> UITestGeofenceScreen {
        let cell = getCellByGeofenceName(app: app, geofenceName: geofenceName)
        XCTAssertTrue(cell.exists, "Geofence added successfully")
        
        return self
    }
    
    func deleteGeofence(geofenceName: String) -> UITestGeofenceScreen {
        let cell = getCellByGeofenceName(app: app, geofenceName: geofenceName)
        let deleteGeofenceButton = cell.buttons.matching(identifier: Identifiers.deleteGeofenceButton).element
        
        XCTAssertTrue(deleteGeofenceButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        deleteGeofenceButton.tap()
        
        return self
    }
    
    func deleteGeofence(index: Int) -> UITestGeofenceScreen {
        let cell = getCellByIndex(app: app, index: index)
        let deleteGeofenceButton = cell.buttons.matching(identifier: Identifiers.deleteGeofenceButton).element
        
        XCTAssertTrue(deleteGeofenceButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        deleteGeofenceButton.tap()
        
        return self
    }
    
    func deleteAllGeofences() {
        _ = UITestTabBarScreen(app: app)
            .tapGeofenceButton()
        
        let table = app.tables[Identifiers.geofenceTableView]
        if (table.waitForExistence(timeout: UITestWaitTime.regular.time)) {
            for _ in (0 ..< table.cells.count) {
                _ = deleteGeofence(index: 0)
                    .confirmDeleteGeofence()
            }
        }
    }
    
    func tapGeofence(geofenceName: String) -> UITestGeofenceScreen {
        let cell = getCellByGeofenceName(app: app, geofenceName: geofenceName)
        
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.regular.time))
        cell.tap()
        
        return self
    }
    
    func confirmDeleteGeofence() -> UITestGeofenceScreen {
        let alert = app.alerts.element
        XCTAssertTrue(alert.waitForExistence(timeout: UITestWaitTime.long.time))
        let responseMessage = alert.label
        XCTAssertEqual(responseMessage, StringConstant.deleteGeofence)
        alert.buttons[StringConstant.ok].tap()
        
        return self
    }
    
    func verifyDeletedGeofence(geofenceName: String) -> UITestGeofenceScreen  {
        let cell = getCellByGeofenceName(app: app, geofenceName: geofenceName)
        XCTAssertTrue(!cell.exists, "Geofence deleted successfully")
        
        return self
    }
    
    func addGeofence(geofenceNameToAdd: String) -> Self {
        let coordinates = generateRandomCoordinatesInNewYork()
        
        return addGeofence(geofenceNameToAdd: geofenceNameToAdd, location: coordinates)
    }
    
    func addGeofence(geofenceNameToAdd: String, location: String, matchCellText: String? = nil, selectDefault: Bool = false) -> Self {
        
        _ = tapAddGeofenceButton()
        
        if(!selectDefault) {
            _ = self.selectGeofenceLocation(location: location, matchCellText: matchCellText)
        }
        
        return self
            .typeGeofenceName(geofenceName: geofenceNameToAdd)
            .tapSaveButton()
            .verifyGeofenceByName(geofenceName: geofenceNameToAdd)
    }
    
    func editGeofence(geofenceName: String, newGeofenceName: String) -> Self {
        let newCoordinates = generateRandomCoordinatesInNewYork()
        
        return tapGeofence(geofenceName: geofenceName)
        .selectGeofenceLocation(location: newCoordinates)
        .setGeofenceRadius()
        .tapSaveButton()
    }
    
    static func generateUniqueGeofenceName() -> String {
        let uniqueName = "GTest\(UUID().uuidString)"
        return uniqueName.prefix(18).description
    }

    // MARK: - Private functions
    private func getCellByGeofenceName(app: XCUIApplication, geofenceName: String) -> XCUIElement {
        let table = app.tables[Identifiers.geofenceTableView]
        XCTAssertTrue(table.waitForExistence(timeout: UITestWaitTime.regular.time))
        
        let predicate = NSPredicate(format: "label CONTAINS %@", geofenceName)
        let cell = table.cells.containing(predicate).element
        return cell
    }
    
    private func getCellByIndex(app: XCUIApplication, index: Int) -> XCUIElement {
        let table = app.tables[Identifiers.geofenceTableView]
        XCTAssertTrue(table.waitForExistence(timeout: UITestWaitTime.regular.time))
        
        let cell = table.cells.element(boundBy: index)
        return cell
    }

    private func generateRandomCoordinatesInUSA() -> String {
        let lat = Double.random(in: 24.7433195...49.3457868)
        let long = Double.random(in: -124.7844079 ... -66.9513812)
        return "\(lat), \(long)"
    }
    
    private func generateRandomCoordinatesInNewYork() -> String {
        // Define the bounding box of New York City
        let newYorkBounds = (minLat: 40.477399, minLon: -74.25909, maxLat: 40.917576, maxLon: -73.700181)

        // Generate a random coordinate within the bounds
        let lat = Double.random(in: newYorkBounds.minLat...newYorkBounds.maxLat)
        let long = Double.random(in: newYorkBounds.minLon...newYorkBounds.maxLon)

        return "\(lat), \(long)"
    }
    
    private func getAddGeofenceTable() -> XCUIElement {
        return app.tables[Identifiers.addGeofenceTableView]
    }
}
