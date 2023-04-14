//
//  LocationServicesTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices
import CoreLocation

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
    
    func testSaveAndGetPrimitiveValue() throws {
        UserDefaults.standard.set("Test", forKey: "Primitive")
        UserDefaults.standard.synchronize()
        XCTAssertEqual(UserDefaults.standard.value(forKey: "Primitive") as! String, "Test", "Expected 'Test' for Key 'Primitive'")
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
    
    func testSaveAndGetObject() throws {
        
        let mapStyle: MapStyleModel = DefaultUserSettings.mapStyle
        UserDefaultsHelper.saveObject(value: mapStyle, key: .mapStyle)
        let savedMapStyle = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        XCTAssertEqual(savedMapStyle?.type, mapStyle.type, "Expected \(mapStyle) value for this key.")
    }
    
    func testSetAndGetAppState() throws {
        
        UserDefaultsHelper.setAppState(state: .prepareDefaultAWSConnect)
        XCTAssertEqual(UserDefaultsHelper.getAppState(), .prepareDefaultAWSConnect, "Expected \(AppState.prepareDefaultAWSConnect) value for this key.")
    }
    
    func testDebounce() throws {
        let debounceManager = DebounceManager(debounceDuration: 1)
        let date1 = Date()

        debounceManager.debounce {
            let date2 = Date()
            let secondsBetween = Int(date2.timeIntervalSince(date1))
            XCTAssertEqual(secondsBetween, 1, "Expected 1 second of debounce")
        }
    }

}
