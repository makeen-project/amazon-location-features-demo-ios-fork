//
//  SettingsDefaultValueHelperTests.swift
//  SettingsDefaultValueHelperTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class SettingsDefaultValueHelperTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCreateDefaulValuesWithEmptyStorage() throws {
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
        let settingsDefaultValueHelper: SettingsDefaultValueHelper = SettingsDefaultValueHelper()
        settingsDefaultValueHelper.createValues()
        XCTAssertEqual(UserDefaultsHelper.get(for: Bool.self, key:  .tollOptions), false, "Create Default Values with empty storage successful")
    }
    
    func testCreateDefaulValuesWithStorage() throws {
        let settingsDefaultValueHelper: SettingsDefaultValueHelper = SettingsDefaultValueHelper()
        settingsDefaultValueHelper.createValues()
        settingsDefaultValueHelper.createValues()
        
        XCTAssertEqual(UserDefaultsHelper.get(for: Bool.self, key:  .tollOptions), false, "Create Default Values with storage successful")
    }

}
