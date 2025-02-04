//
//  SettingsUITests.swift
//  Amazon Location Demo UITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

final class SettingsUITests: LocationServicesUITests {
    
    enum Constants {
        static let departureAddress = "Kyiv"
        static let destinationAddress = "Poltava"
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSettingsOptions() throws {
        let app = startApp()

        let _ = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .waitAWSCloudRow()
            .waitMapStyleRow()
            .waitRouteOptionsRow()
    }

    func testRouteOptions() throws {
        let app = startApp(allowPermissions: true)
        var routeOptionsScreen = UITestTabBarScreen(app: app)
            .tapSettingsButton()
            .tapRouteOptionsRow()
            .waitForAvoidTollsContainer()
            .waitForAvoidFerriesContainer()
        
        XCTAssertTrue(routeOptionsScreen.isOnAvoidTollsSwitch())
        XCTAssertTrue(routeOptionsScreen.isOnAvoidFerriesSwitch())
        
        routeOptionsScreen = routeOptionsScreen
            .switchAvoidTolls()
        XCTAssertFalse(routeOptionsScreen.isOnAvoidTollsSwitch())
        
        routeOptionsScreen = routeOptionsScreen
            .switchAvoidFerries()
        XCTAssertFalse(routeOptionsScreen.isOnAvoidFerriesSwitch())
        
        let routingScreen = routeOptionsScreen
            .tapBackButton()
            .getTabBarScreen()
            .tapExploreButton()
            .tapRouting()
            .selectDepartureTextField()
            .typeInDepartureTextField(text: Constants.departureAddress)
            .selectSearchResult(index: 1)
            .selectDestinationTextField()
            .typeInDestinationTextField(text: Constants.destinationAddress)
            .selectSearchResult(index: 1)
            .waitForRouteTypesContainer()
            .switchRouteOptionsVisibility()
        
        XCTAssertFalse(routingScreen.isOnAvoidTollsSwitch())
        XCTAssertFalse(routingScreen.isOnAvoidFerriesSwitch())
    }
    
    func testMapStyleChanges() throws {
        let app = startApp(allowPermissions: true)
        var exploreScreen = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
        
        exploreScreen = testMapStyle(screen: exploreScreen, style: .monochrome)
    }
    
    func testMapStyle(screen: UITestExploreScreen, style: MapStyleImages) -> UITestExploreScreen {
        let screenshotBefore = screen.takeMapScreenshot()
        
        var mapStyleScreen = screen.getTabBarScreen()
            .tapSettingsButton()
            .tapMapStyleRow()
        
        let screenShotShouldBeChanged = !mapStyleScreen.isCellSelected(for: style)
        
        mapStyleScreen = mapStyleScreen
            .select(style: style)
        XCTAssertTrue(mapStyleScreen.isCellSelected(for: style))
        Thread.sleep(forTimeInterval: 2)
        let settingsScreen = mapStyleScreen
            .tapBackButton()
        Thread.sleep(forTimeInterval: 2)
        let exploreScreen = settingsScreen
            .getTabBarScreen()
            .tapExploreButton()
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
