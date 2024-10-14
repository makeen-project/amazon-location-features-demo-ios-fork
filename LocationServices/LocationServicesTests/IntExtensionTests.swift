//
//  IntExtensionTests.swift
//  LocationServicesTests
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

    func testConvertIntToM() throws {
        let km: Int = 1000
       XCTAssertEqual(km.fromatToKmString(), "1000.0 m", "Expected string km")
    }

    func testConvertInt64ToM() throws {
        let km: Int64 = 1000
       XCTAssertEqual(km.fromatToKmString(), "1000.0 m", "Expected string km")
    }
    
    func testConvertIntToKM() throws {
        let km: Int = 1001
       XCTAssertEqual(km.fromatToKmString(), "1.00 km", "Expected string km")
    }

    func testConvertInt64ToKM() throws {
        let km: Int64 = 1001
       XCTAssertEqual(km.fromatToKmString(), "1.00 km", "Expected string km")
    }
}
