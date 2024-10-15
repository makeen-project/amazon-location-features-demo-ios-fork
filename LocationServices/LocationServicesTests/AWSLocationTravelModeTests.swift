//
//  AWSLocationTravelModeTests.swift
//  AWSLocationTravelModeTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0


import XCTest
@testable import LocationServices
import AWSLocation

final class AWSLocationTravelModeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitWithWalking() throws {
        let travelMode = LocationClientTypes.TravelMode(routeType: .walking)
        XCTAssertEqual(travelMode, .walking, "Route mode Waking expected")
    }
    
    func testInitWithCar() throws {
        let travelMode = LocationClientTypes.TravelMode(routeType: .car)
        XCTAssertEqual(travelMode, .car, "Route mode Car expected")
    }
    
    func testInitWithTruck() throws {
        let travelMode = LocationClientTypes.TravelMode(routeType: .truck)
        XCTAssertEqual(travelMode, .truck, "Route mode Waking expected")
    }

}
