//
//  IntExtensionTests.swift
//  IntExtensionTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class IntExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConvertToKM() throws {
        let km: Int = 1000
       XCTAssertEqual(km.convertToKm(), "1000.0 m", "Expected string km")
    }

}
