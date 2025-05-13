//
//  UITestTrackingScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

import XCTest

struct UITestTrackingScreen: UITestScreen {
    let app: XCUIApplication
    
    private enum Identifiers {
        static var awsConnectTitleLabel: String { ViewsIdentifiers.AWSConnect.awsConnectTitleLabel }
        static var trackingActionButton: String { ViewsIdentifiers.Tracking.trackingActionButton }
        static var trackingPointsExpandButton: String { ViewsIdentifiers.Tracking.trackingPointsExpandButton }
        static var trackingPointsTableView: String { ViewsIdentifiers.Tracking.trackingPointsTableView }
        static var trackingSimulationScrollView: String { ViewsIdentifiers.Tracking.trackingSimulationScrollView }
        static var bottomGrabberView: String {
            ViewsIdentifiers.General.bottomGrabberView
        }
        static var trackingStartedLabel: String { ViewsIdentifiers.Tracking.trackingStartedLabel }
        static var trackingStoppedLabel: String { ViewsIdentifiers.Tracking.trackingStoppedLabel }
        static var imageAnnotationView: String { ViewsIdentifiers.General.imageAnnotationView }
        
        static var startTrackingSimulationButton: String { ViewsIdentifiers.Tracking.startTrackingSimulationButton }
        static var trackingSimulationStartedLabel: String { ViewsIdentifiers.Tracking.trackingSimulationStartedLabel }
    }
    
    enum Constants {
        //static let continueToTracker = StringConstant.continueToTracker
        static let geofenceEntered = "\(StringConstant.tracker) \(StringConstant.entered)"
        static let geofenceExited = "\(StringConstant.tracker) \(StringConstant.exited)"
    }

    func tapStartTrackingSimulationButton() -> Self {
        let enableTrackingButton = app.buttons.matching(identifier: Identifiers.startTrackingSimulationButton).element
          
          XCTAssertTrue(enableTrackingButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        enableTrackingButton.tap()
        return self
    }
    
    func continueTrackingAlert() -> Self {
        let alert = app.alerts.element
        if (alert.waitForExistence(timeout: UITestWaitTime.regular.time)) {
            let continueButton = alert.buttons.firstMatch
            XCTAssertTrue(continueButton.waitForExistence(timeout: UITestWaitTime.regular.time))
            continueButton.tap()
        }
        return self
    }
    
    func tapStartTrackingButton() -> Self {
        let trackingActionButton = app.buttons.matching(identifier: Identifiers.trackingActionButton).element
          
        XCTAssertTrue(trackingActionButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        trackingActionButton.tap()
        return self
    }
    
    func tapStopTrackingButton() -> Self {
        let trackingActionButton = app.buttons.matching(identifier: Identifiers.trackingActionButton).element
         
        XCTAssertTrue(trackingActionButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        trackingActionButton.tap()
        return self
    }
    
    func tapTrackingPointsExpandButton() -> Self {
        let trackingActionButton = app.buttons.matching(identifier: Identifiers.trackingPointsExpandButton).element
          
        XCTAssertTrue(trackingActionButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        trackingActionButton.tap()
        return self
    }
    
    func verifyTrackingStartedLabel() -> Self {
        let label = app.staticTexts[Identifiers.trackingStartedLabel]
        XCTAssertTrue(label.waitForExistence(timeout: UITestWaitTime.regular.time))
        return self
    }
    
    func verifyTrackingStoppedLabel() -> Self {
        let label = app.staticTexts[Identifiers.trackingStoppedLabel]
        XCTAssertTrue(label.waitForExistence(timeout: UITestWaitTime.regular.time))
        return self
    }
    
    func verifyTrackingPoints() -> Self {
        let table = app.tables[Identifiers.trackingPointsTableView]
        XCTAssertGreaterThan(table.cells.count, 0, "Tracking points list should have at least one row")
        return self
    }
    
    func swipeUpHistoryView() -> Self {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return self }
        let view = app.otherElements[Identifiers.bottomGrabberView]
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.regular.time))
        view.tap()
        Thread.sleep(forTimeInterval: 1)
        return self
    }
    
    func waitForGeofenceEnteredAlert(geofenceName: String) -> Self {
        let alert = app.alerts.element
        XCTAssertTrue(alert.waitForExistence(timeout: UITestWaitTime.long.time))
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", Constants.geofenceEntered)
        let elementQuery = app.staticTexts.containing(predicate)
        XCTAssertGreaterThan(elementQuery.count, 0)
        alert.buttons.firstMatch.tap()
        return self
    }
    
    func waitForGeofenceExitedAlert(geofenceName: String) -> Self {
        let alert = app.alerts.element
        XCTAssertTrue(alert.waitForExistence(timeout: UITestWaitTime.long.time))
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", Constants.geofenceExited)
        let elementQuery = app.staticTexts.containing(predicate)
        XCTAssertGreaterThan(elementQuery.count, 0)
        alert.buttons.firstMatch.tap()
        return self
    }
    
    func waitForTrackingPoints() -> Self {
        let predicate = NSPredicate(format: "identifier CONTAINS[c] %@", "bus_route")
        let annotationImage = app.descendants(matching: .any).matching(predicate).element
        if(annotationImage.waitForExistence(timeout: UITestWaitTime.long.time)) {
            XCTAssertTrue(true, "Tracking points found")
        }
        else {
            XCTFail("Tracking points not found")
        }
        return self
    }
    
    func verifyTrackingSimulationStartedLabel() -> Self {
        let label = app.staticTexts[Identifiers.trackingStartedLabel]
        XCTAssertTrue(label.waitForExistence(timeout: UITestWaitTime.regular.time))
        return self
    }
    
    func waitForTrackingSimulation() -> UITestAWSScreen {
        let label = XCUIApplication().staticTexts[Identifiers.trackingStoppedLabel]
        XCTAssertEqual(label.label, StringConstant.Tracking.noTracking)
        
        return UITestAWSScreen(app: app)
    }
}
