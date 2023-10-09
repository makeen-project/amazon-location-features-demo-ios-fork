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
        static var enableTrackingButton: String { ViewsIdentifiers.Tracking.enableTrackingButton }
        static var trackingActionButton: String { ViewsIdentifiers.Tracking.trackingActionButton }
        static var trackingHistoryTableView: String {
            ViewsIdentifiers.Tracking.trackingHistoryTableView }
        static var trackingHistoryScrollView: String { ViewsIdentifiers.Tracking.trackingHistoryScrollView }
        static var trackingStartedLabel: String { ViewsIdentifiers.Tracking.trackingStartedLabel }
        static var trackingStoppedLabel: String { ViewsIdentifiers.Tracking.trackingStoppedLabel }
        static var deleteTrackingDataButton: String { ViewsIdentifiers.Tracking.deleteTrackingDataButton }
        static var imageAnnotationView: String { ViewsIdentifiers.General.imageAnnotationView }
    }
    
    enum Constants {
        static let continueToTracker = StringConstant.continueToTracker
        static let geofenceEntered = "\(StringConstant.tracker) \(StringConstant.entered)"
        static let geofenceExited = "\(StringConstant.tracker) \(StringConstant.exited)"
    }
    
    func waitForAWSConnectionScreen() -> UITestAWSScreen {
        let label = app.otherElements[Identifiers.awsConnectTitleLabel].firstMatch
        XCTAssertFalse(label.waitForExistence(timeout: UITestWaitTime.regular.time))
        
        return UITestAWSScreen(app: app)
    }
    
    func tapEnableTrackingButton() -> Self {
        let enableTrackingButton = app.buttons.matching(identifier: Identifiers.enableTrackingButton).element
          
          XCTAssertTrue(enableTrackingButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        enableTrackingButton.tap()
          return self
    }
    
    func continueTrackingAlert() -> Self {
        let alert = app.alerts.element
        if (alert.waitForExistence(timeout: UITestWaitTime.regular.time)) {
            let responseMessage = alert.label
            XCTAssertEqual(responseMessage, StringConstant.enableTracking)
            let continueButton = alert.buttons[StringConstant.continueToTracker]
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
    
    func verifyTrackingHistoryStarted() -> Self {
        let table = app.tables[Identifiers.trackingHistoryTableView]
        XCTAssertTrue(table.waitForExistence(timeout: UITestWaitTime.regular.time))
        let cell = table.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: UITestWaitTime.long.time))
        return self
    }
    
    func verifyTrackingHistoryDeleted() -> Self {
        let table = app.tables[Identifiers.trackingHistoryTableView]
        XCTAssertTrue(table.waitForExistence(timeout: UITestWaitTime.regular.time))
        let cellCount = table.cells.count
        XCTAssertEqual(cellCount, 0)
        return self
    }
    
    func swipeUpHistoryView() -> Self {
        let view = app.scrollViews[Identifiers.trackingHistoryScrollView]
        XCTAssertTrue(view.waitForExistence(timeout: UITestWaitTime.regular.time))
        view.swipeUp()
        Thread.sleep(forTimeInterval: 1)
        return self
    }
    
    func tapDeleteTrackingDataButton() -> Self {
        let deleteTrackingDataButton = app.buttons.matching(identifier: Identifiers.deleteTrackingDataButton).element
         
        XCTAssertTrue(deleteTrackingDataButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        deleteTrackingDataButton.tap()
        return self
    }
    
    func verifyTrackingAnnotations() -> Self {
        let annotationImage = app.descendants(matching: .any).matching(identifier: Identifiers.imageAnnotationView).firstMatch
        if(annotationImage.waitForExistence(timeout: UITestWaitTime.long.time)) {
            XCTAssertTrue(true, "Tracking points found")
        }
        else {
            let alert = app.alerts.element
            if(alert.waitForExistence(timeout: UITestWaitTime.long.time)){
                alert.buttons.firstMatch.tap()
                if(annotationImage.waitForExistence(timeout: UITestWaitTime.long.time)) {
                    XCTAssertTrue(true, "Tracking points found")
                }
                else {
                    _ = verifyTrackingHistoryStarted()
                }
            }
            else {
                _ = verifyTrackingHistoryStarted()
            }
        }
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
    
}
