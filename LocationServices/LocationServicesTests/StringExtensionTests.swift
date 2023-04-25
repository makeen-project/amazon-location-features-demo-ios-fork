//
//  StringExtensionTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class StringExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConvertIdentityPoolIdToRegionType() throws {
        let idpID = "us-east-2:35841fd0-257a-46c5-b44e-fd289ab6e194"
        XCTAssertEqual(idpID.toRegionType(), .USEast2, "Expected region type from the provided text")
    }

    func testConvertIdentityPoolIdToRegionString() throws {
        let idpID = "us-east-2:35841fd0-257a-46c5-b44e-fd289ab6e194"
        XCTAssertEqual(idpID.toRegionString(), "us-east-2", "Expected region string from the provided text")
    }
    
    func testCreateInitial() throws {
       let model =  "South America"
        XCTAssertEqual(model.createInitial(), "SA", "testCreateInitial successful")
    }
    
    func testConvertTextToCoordinate() throws {
       let text =  "40.75782863140032, -73.98573463547527"
        XCTAssertEqual(text.convertTextToCoordinate().first?.stringValue, "-73.98573463547527", "testConvertTextToCoordinate successful")
    }

    func testFormatAddressField() throws {
       let address =  "1501 Broadway, New York, NY 10036, United States"
        XCTAssertEqual(address.formatAddressField().first, "1501 Broadway", "Expected formatted address")
    }
    
    func testIsCoordinate() throws {
       let coordinate =  "40.75782863140032, -73.98573463547527"
        XCTAssertEqual(coordinate.isCoordinate(), true, "testIsCoordinate successful")
    }


}
