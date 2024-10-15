//
//  DoubleExtensionTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class DoubleExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConvertSecondsToMinString() throws {
        let seconds: Double = 3600
       XCTAssertEqual(seconds.convertSecondsToMinString(), "1 hr", "Expected formatted 1 hr string")
    }
    
    func testConvertKMToM() throws {
        let km: Double = 1
       XCTAssertEqual(km.convertKMToMeters(), 1000, "Expected 1000 M")
    }
    
    func testConvertFormattedKMString() throws {
        let km: Double = 1
       XCTAssertEqual(km.convertFormattedKMString(), "1.00 km", "Expected formatted KM 1 km string")
    }

}
