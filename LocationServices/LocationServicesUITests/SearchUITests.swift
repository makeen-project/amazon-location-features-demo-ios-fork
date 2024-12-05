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
        static let geocode = "115.9248736, -31.9627092"
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
}
