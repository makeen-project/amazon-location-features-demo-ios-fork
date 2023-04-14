//
//  LocationServicesTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class LocationServicesTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // remove whole user defaults keys and values
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUserDefaultsSave() throws {
        // scenario
        // init UserDefaults
        // save bool value
        // read value check result
        
        let testBoolValue = true
        
        UserDefaultsHelper.save(value: testBoolValue, key: .ferriesOptions)
        XCTAssertEqual(UserDefaultsHelper.get(for: Bool.self, key: .ferriesOptions), testBoolValue, "Expected \(testBoolValue) value for this key.")
        
    }
}
