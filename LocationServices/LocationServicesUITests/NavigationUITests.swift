//
//  NavigationUITests.swift
//  Amazon Location Demo UITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
import CoreLocation

final class NavigationUITests: LocationServicesUITests {
    
    enum Constants {
        static let departureAddress = "Kyiv"
        static let destinationAddress = "Poltava"
        
        static let tollsDepartureAddress = "auburn sydney"
        static let tollsDestinationAddress = "beach sydney"
        
        static let ferriesDepartureAddress = "port fouad"
        static let ferriesDestinationAddress = "port said"
        
        static let timesSquareAddress = "New York Times Square"
        
        static let walkDepartureAddress = "cloverdale perth"
        static let walkDestinationAddress = "Kewdale Perth"
        
        static let navigationStartLocation = CLLocation(latitude: 40.728489, longitude: -74.007167)
        static let navigationMoveLocation = CLLocation(latitude: 40.741940, longitude: -73.974948)
        static let navigationEndLocation = CLLocation(latitude: 40.743785, longitude: -73.973602)
        
        static var navigationEndCoordinateSearchString: String {
            return "\(navigationEndLocation.coordinate.latitude), \(navigationEndLocation.coordinate.longitude)"
        }
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMapInteractionAndStyleAndNavigation() throws {
        let app = startApp(allowPermissions: false)
        var screen = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .tapMapStyles()
            .select(style: .street)
            .select(style: .light)
            .select(style: .light)
            .tapCloseButton()
            .tapRouting()
            .selectDepartureTextField()
            .typeInDepartureTextField(text: Constants.departureAddress)
            .selectSearchResult(index: 1)
            .selectDestinationTextField()
            .typeInDestinationTextField(text: Constants.destinationAddress)
            .selectSearchResult(index: 1)
            .waitForRouteTypesContainer()
            .activate(mode: .car)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            screen = screen.tapRoutesButton()
        }
        screen = screen
            .waitForRootView()
    }
    
    func testRouteTypes() throws {
        let app = startApp(allowPermissions: false)
        var screen = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .tapRouting()
            .selectDepartureTextField()
            .typeInDepartureTextField(text: Constants.walkDepartureAddress)
            .selectSearchResult(index: 1)
            .selectDestinationTextField()
            .typeInDestinationTextField(text: Constants.walkDestinationAddress)
            .selectSearchResult(index: 1)
            .waitForRouteTypesContainer()
            .waitForNonEmptyRouteEstimatedTime(for: .car)
            .waitForNonEmptyRouteEstimatedDistance(for: .car)
            .waitForNonEmptyRouteEstimatedTime(for: .walk)
            .waitForNonEmptyRouteEstimatedDistance(for: .walk)
            .waitForNonEmptyRouteEstimatedTime(for: .truck)
            .waitForNonEmptyRouteEstimatedDistance(for: .truck)
            .activate(mode: .car)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            screen = screen.tapRoutesButton()
        }
        screen = screen
            .waitForRootView()
            .tapExitButton()
            .waitForRouteTypesContainer()
            .activate(mode: .walk)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            screen = screen.tapRoutesButton()
        }
        screen = screen
            .waitForRootView()
            .tapExitButton()
            .waitForRouteTypesContainer()
            .activate(mode: .truck)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            screen = screen.tapRoutesButton()
        }
        let _ = screen
            .waitForRootView()
            .tapExitButton()
            .waitForRouteTypesContainer()
    }
    
    func testSwapRoute() throws {
        let app = startApp(allowPermissions: false)
        let screenBeforeSwap = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .tapRouting()
            .selectDepartureTextField()
            .typeInDepartureTextField(text: Constants.departureAddress)
            .selectSearchResult(index: 1)
            .selectDestinationTextField()
            .typeInDestinationTextField(text: Constants.destinationAddress)
            .selectSearchResult(index: 1)

        let departureBeforeSwap = screenBeforeSwap.getDeparturePlace()
        let destinationBeforeSwap = screenBeforeSwap.getDestinationPlace()
        
        let screenAfterSwap = screenBeforeSwap
            .swapRoute()
        
        let departureAfterSwap = screenAfterSwap.getDeparturePlace()
        let destinationAfterSwap = screenAfterSwap.getDestinationPlace()
        
        XCTAssertEqual(departureBeforeSwap, destinationAfterSwap)
        XCTAssertEqual(destinationBeforeSwap, departureAfterSwap)
    }
    
    func testRouteTollsOption() throws {
        let app = startApp(allowPermissions: false)
        var screen = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .tapRouting()
            .selectDepartureTextField()
            .typeInDepartureTextField(text: Constants.tollsDepartureAddress)
            .selectSearchResult(index: 1)
            .selectDestinationTextField()
            .typeInDestinationTextField(text: Constants.tollsDestinationAddress)
            .selectSearchResult(index: 1)
            .waitForRouteTypesContainer()
            .waitForMapToBeRendered()

        let screenshotBefore = screen.getMapScreenshot()

        screen = screen
            .switchRouteOptionsVisibility()
            .switchAvoidTolls()
            .waitForMapToBeRendered()

        let screenshotAfter = screen.getMapScreenshot()
        XCTAssertNotEqual(screenshotBefore.pngRepresentation, screenshotAfter.pngRepresentation)
    }
    
    func testRouteFerriesOption() throws {
        let app = startApp(allowPermissions: false)
        var screen = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .tapRouting()
            .selectDepartureTextField()
            .typeInDepartureTextField(text: Constants.ferriesDepartureAddress)
            .selectSearchResult(index: 1)
            .selectDestinationTextField()
            .typeInDestinationTextField(text: Constants.ferriesDestinationAddress)
            .selectSearchResult(index: 1)
            .waitForRouteTypesContainer()
            .waitForMapToBeRendered()

        let screenshotBefore = screen.getMapScreenshot()

        screen = screen
            .switchRouteOptionsVisibility()
            .switchAvoidFerries()
            .waitForMapToBeRendered()

        let screenshotAfter = screen.getMapScreenshot()
        XCTAssertNotEqual(screenshotBefore.pngRepresentation, screenshotAfter.pngRepresentation)
    }
    
    func testMapAdjustedForRoute() throws {
        let app = startApp(allowPermissions: false)
        let screen = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .tapRouting()
            .selectDepartureTextField()
            .typeInDepartureTextField(text: Constants.departureAddress)
            .selectSearchResult(index: 1)
            .selectDestinationTextField()
            .typeInDestinationTextField(text: Constants.destinationAddress)
            .selectSearchResult(index: 1)
            .waitForRouteTypesContainer()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            UITestTabBarScreen(app: app).showFullScreen()
        }
        
        let _ = screen
            .waitForMapToBeRendered()
    }
    
    func testMyLocationOption() throws {
        let app = startApp()
        var screen = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .tapRouting()
            .selectDepartureTextField()
            .selectSearchResult(index: 0)
        
        let textField = screen.getDeparturePlace()
        XCTAssertEqual(textField, StringConstant.myLocation)
        
        screen = screen
            .selectDestinationTextField()
            .typeInDestinationTextField(text: Constants.timesSquareAddress)
            .selectSearchResult(index: 1)
            .waitForRouteTypesContainer()
    }
    
    func testNavigation() throws {
        XCUIDevice.shared.location = .init(location: Constants.navigationStartLocation)
        let app = startApp()
        var screen = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .tapSearchTextField()
            .type(text: Constants.navigationEndCoordinateSearchString)
            .waitForResultsInTable()
            .tapFirstCell()
            .waitForPoiCardView()
            .tapDirectionButton()
            .waitForRouteTypesContainer()
            .activate(mode: .car)
    }
}
