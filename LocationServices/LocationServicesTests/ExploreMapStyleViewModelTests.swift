//
//  ExploreMapStyleViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class ExploreMapStyleViewModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadDataWithData() throws {
        let settingsDefaultValueHelper = SettingsDefaultValueHelper()
        settingsDefaultValueHelper.createValues()
        let exploreMapStyleViewModel = ExploreMapStyleViewModel()
        exploreMapStyleViewModel.loadData()
        XCTAssert(true)
    }
    
    func testLoadDataWithEmptyData() throws {
        let exploreMapStyleViewModel = ExploreMapStyleViewModel()
        exploreMapStyleViewModel.loadData()
        XCTAssert(true)
    }
    
    func testGetItemsCount() throws {
        let exploreMapStyleViewModel = ExploreMapStyleViewModel()
        XCTAssertGreaterThan(exploreMapStyleViewModel.getItemsCount(), 0, "Expected data count greater than 0")
    }
    
    func testGetItem() throws {
        let exploreMapStyleViewModel = ExploreMapStyleViewModel()
        XCTAssertEqual(exploreMapStyleViewModel.getItem(with: 0), .esri, "Expected esri map style")
    }
}
