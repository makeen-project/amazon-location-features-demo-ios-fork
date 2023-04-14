//
//  ReachabilityTests.swift
//  ReachabilityTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class ReachabilityTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStartMonitoringReturnInternetIsReachable() throws {
        Reachability.shared.startMonitoring()
        XCTAssertEqual(Reachability.shared.isInternetReachable, true,  "Expected internet is reachable")
    }
    
    func testStartMonitoringStatusValue() throws {
        Reachability.shared.startMonitoring()
        XCTAssertEqual(Reachability.shared.currentStatus, .satisfied,  "Expected internet status is satisfied")
    }
}
