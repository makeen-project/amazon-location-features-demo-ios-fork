//
//  DebounceManagerTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class DebounceManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDebounce() throws {
        let debounceManager = DebounceManager(debounceDuration: 1)
        let date1 = Date()

        debounceManager.debounce {
            let date2 = Date()
            let secondsBetween = Int(date2.timeIntervalSince(date1))
            XCTAssertGreaterThanOrEqual(secondsBetween, 1, "Expected atleast 1 second of debounce")
        }
    }

}
