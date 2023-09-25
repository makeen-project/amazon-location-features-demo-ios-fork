//
//  SearchUITests.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

final class SearchUITests: LocationServicesUITests {
    
    enum Constants {
        static let addressName = "44 Boobialla Street, Corbie Hill, Australia"
        static let geocode = "-31.9627092, 115.9248736"
        static let searchText = "Rio Tinto"
        static let category = "School"
        static let timesSquareAddress = "New York Times Square"
    }
    
    override func setUp() {
        super.setUp()
    }

    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    func testSearchByAddressName() throws {
        let app = startApp()
        let _ = UITestExploreScreen(app: app)
            .tapSearchTextField()
            .waitForSearchRootView()
            .type(text: Constants.addressName)
            .tapKeyboardReturnButton()
            .waitForResultsInTable()
    }
    
    func testSearchByGeocodeLocation() throws {
        let app = startApp()
        let _ = UITestExploreScreen(app: app)
            .tapSearchTextField()
            .waitForSearchRootView()
            .type(text: Constants.geocode)
            .tapKeyboardReturnButton()
            .waitForResultsInTable()
            .hasAddressInFirstCell()
    }
    
    func testSearchBoxPosition() throws {
        //don't need this test for ipads
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        let app = startApp()
        let _ = UITestExploreScreen(app: app)
            .waitForSeachBarToBeRendered()
            .checkSearchBarInCorrectPosition()
    }
    
//    func testSearchScreenStates() throws {
//        //don't need this test for ipads
//        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
//        let app = startApp()
//        let _ = UITestExploreScreen(app: app)
//            .tapSearchTextField()
//            .waitForSearchRootView()
//            .lightSwipeDownStateShouldBeChanged()
//            .waitForSearchRootView()
//            .lightSwipeDownStateShouldBeChanged()
//            .waitForSearchRootView()
//            .lightSwipeDownStateShouldBeChanged()
//            .screenShouldBeClosed()
//    }
    
    func testSearch() throws {
        let app = startApp()
        let _ = UITestExploreScreen(app: app)
            .tapSearchTextField()
            .waitForSearchRootView()
            .type(text: Constants.searchText)
            .waitForResultsInTable()
    }
    
    func testSearchByCategory() throws {
        let app = startApp()
        let _ = UITestExploreScreen(app: app)
            .tapSearchTextField()
            .waitForSearchRootView()
            .type(text: Constants.category)
            .waitForResultsInTable()
    }
    
//    func testNoResults() throws {
//        let app = startApp()
//        let _ = UITestExploreScreen(app: app)
//            .tapSearchTextField()
//            .waitForSearchRootView()
//            .tapKeyboardReturnButton()
//            .waitForNoResultsView()
//    }
    
    func testSearchWithAddressPoiCard() {
        let app = startApp(allowPermissions: true)
        
        let _ = UITestExploreScreen(app: app)
            .tapSearchTextField()
            .waitForSearchRootView()
            .type(text: Constants.timesSquareAddress)
            .tapFirstCell()
            .waitForPoiCardView()
            .waitForTravelTimeLabel()
            .waitForDirectionButton()
    }
    
    func testPoiCircle() {
        let app = startApp(allowPermissions: true)
        
        let _ = UITestExploreScreen(app: app)
            .tapSearchTextField()
            .waitForSearchRootView()
            .type(text: Constants.timesSquareAddress)
            .tapFirstCell()
            .waitForPoiCardView()
            .waitForPoiCicle()
    }
    
    func testSearchResultsOnMap() {
        let app = startApp(allowPermissions: true)
        
        let _ = UITestExploreScreen(app: app)
            .tapSearchTextField()
            .waitForSearchRootView()
            .type(text: Constants.timesSquareAddress)
            .waitForResultsInTable()
            .validateResultsOnMap()
    }
    
    func testNavigationSearch() {
        let app = startApp(allowPermissions: true)
        let searchScreen = UITestExploreScreen(app: app)
            .waitForMapToBeRendered()
            .tapSearchTextField()
            .waitForSearchRootView()
            .type(text: Constants.addressName)
            .waitForResultsInTable()
        
        let searchResultsOnSearch = searchScreen.getCellsInfo()
        
        let routingScreen = searchScreen
            .close()
            .tapRouting()
            .selectDepartureTextField()
            .typeInDepartureTextField(text: Constants.addressName)
            .waitForResultsInTable(minimumCount: 2)
        
        let searchResultsOnRouting = routingScreen.getCellsInfo()
        
        XCTAssertEqual(searchResultsOnSearch, searchResultsOnRouting)
    }
    
    func testPoiCardDirectionButton() {
        let app = startApp(allowPermissions: true)
        
        let _ = UITestExploreScreen(app: app)
            .tapSearchTextField()
            .waitForSearchRootView()
            .type(text: Constants.timesSquareAddress)
            .tapFirstCell()
            .waitForPoiCardView()
            .tapDirectionButton()
            .waitForRouteTypesContainer()
    }
}
