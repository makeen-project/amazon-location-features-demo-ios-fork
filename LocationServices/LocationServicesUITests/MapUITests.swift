//
//  MapUITests.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

final class MapUITests: LocationServicesUITests {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMapAppearance() throws {
        let app = startApp()
        let _ = UITestExploreScreen(app: app).waitForMapToBeRendered()
    }
    
    func testMapZoomIn() throws {
        let app = startApp(allowPermissions: false)
        let _ = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .zoomInWithPinch()
    }
    
    func testMapZoomInByTap() throws {
        let app = startApp(allowPermissions: false)
        let _ = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .zoomInWithTap()
    }
    
    func testMapZoomOut() throws {
        let app = startApp(allowPermissions: false)
        let _ = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .zoomOut()
    }
    
    func testMapMaxZoomIn() throws {
        let app = startApp(allowPermissions: false)
        let _ = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .zoomInToMax()
            .zoomInWithPinchFails()
    }
    
    func testMapMaxZoomOut() throws {
        let app = startApp(allowPermissions: false)
        let _ = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .zoomOutToMax()
            .zoomOutFails()
    }
    
    func testUserLocationAnnotation() throws {
        let app = startApp(allowPermissions: true)
        let _ = UITestExploreScreen(app: app)
            .waitForUserLocationAnnotation()
    }
    
    func testLocateMeButton() throws {
        let app = startApp(allowPermissions: true)
        let _ = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .waitForUserLocationAnnotation()
            .swipeMap(direction: .left)
            .checkAbsenceOfUserLocationAnnotation()
            .tapLocateMeButton()
            .waitForUserLocationAnnotation()
    }
    
    func testMapStyleChanges() throws {
        let app = startApp(allowPermissions: false)
        var exploreScreen = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
        
        exploreScreen = testMapStyle(screen: exploreScreen, style: .light)
        exploreScreen = testMapStyle(screen: exploreScreen, style: .street)
        exploreScreen = testMapStyle(screen: exploreScreen, style: .navigation)
        exploreScreen = testMapStyle(screen: exploreScreen, style: .darkGray)
        exploreScreen = testMapStyle(screen: exploreScreen, style: .lightGray)
        exploreScreen = testMapStyle(screen: exploreScreen, style: .Imagery)
        exploreScreen = testMapStyle(screen: exploreScreen, style: .explore)
        exploreScreen = testMapStyle(screen: exploreScreen, style: .contrast)
        exploreScreen = testMapStyle(screen: exploreScreen, style: .exploreTruck)
        exploreScreen = testMapStyle(screen: exploreScreen, style: .hereImagery)
        exploreScreen = testMapStyle(screen: exploreScreen, style: .hybrid)
    }
    
    func testMapStyle(screen: UITestExploreScreen, style: MapStyleImages) -> UITestExploreScreen {
        let screenshotBefore = screen.takeMapScreenshot()
        
        var mapStyleScreen = screen
            .tapMapStyles()
        
        let screenShotShouldBeChanged = !mapStyleScreen.isCellSelected(for: style)
        
        mapStyleScreen = mapStyleScreen
            .select(style: style)
        XCTAssertTrue(mapStyleScreen.isCellSelected(for: style))
        
        let exploreScreen = mapStyleScreen
            .tapCloseButton()
            .waitForMapToBeRendered()
        
        let screenshotAfter = exploreScreen.takeMapScreenshot()
        let comparator = UITestScreenshotComparator(allowedDifference: 0.01)
        let areScreenshotsEqual = comparator.areEqual(originalImage: screenshotBefore.image, changedImage: screenshotAfter.image)
        if screenShotShouldBeChanged {
            XCTAssertFalse(areScreenshotsEqual, UITestConstants.mapNotChangedError)
        } else {
            XCTAssertTrue(areScreenshotsEqual, UITestConstants.mapChangedError)
        }
        
        return exploreScreen
    }
}
