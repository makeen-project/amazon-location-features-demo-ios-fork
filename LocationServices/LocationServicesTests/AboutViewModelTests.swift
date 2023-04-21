//
//  AboutViewModelTests.swift
//  AboutViewModelTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class AboutViewModelTests: XCTestCase {

    let aboutViewModel = AboutViewModel()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetCellItems() throws {
        let indexPath = IndexPath(row: 1, section: 0)
        let item = aboutViewModel.getCellItems(indexPath)
                
        XCTAssertEqual(item.type, .version, "Expected cell item type")
    }
    
    func testGetItemCount() throws {
        XCTAssertEqual(aboutViewModel.getItemCount(), 4, "Expected cell item type")
    }

}
