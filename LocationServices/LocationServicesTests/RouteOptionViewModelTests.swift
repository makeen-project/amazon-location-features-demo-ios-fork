//
//  RouteOptionViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class RouteOptionViewModelTests: XCTestCase {

    let routeOptionViewModel = RouteOptionViewModel()
    var mockRouteOptionViewModelOutputDelegate: MockRouteOptionViewModelOutputDelegate!
    
    override func setUpWithError() throws {
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
        mockRouteOptionViewModelOutputDelegate = MockRouteOptionViewModelOutputDelegate()
        routeOptionViewModel.delegate = mockRouteOptionViewModelOutputDelegate
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSaveTollOption() throws {
        routeOptionViewModel.saveTollOption(state: true)
       XCTAssertEqual(UserDefaultsHelper.get(for: Bool.self, key: .tollOptions), true, "Expected true toll options")
    }
    
    func testSaveFerriesOption() throws {
        routeOptionViewModel.saveFerriesOption(state: true)
       XCTAssertEqual(UserDefaultsHelper.get(for: Bool.self, key: .ferriesOptions), true, "Expected true ferries options")
    }
    
    func testLoadData() {
        UserDefaultsHelper.save(value: true, key: .tollOptions)
        UserDefaultsHelper.save(value: false, key: .ferriesOptions)
        routeOptionViewModel.loadData()
        XCTAssertEqual(mockRouteOptionViewModelOutputDelegate.tollOption, true, "Expected true ferries options")
        XCTAssertEqual(mockRouteOptionViewModelOutputDelegate.ferriesOption, false, "Expected true ferries options")
    }

}

class MockRouteOptionViewModelOutputDelegate: RouteOptionViewModelOutputDelegate {
    var tollOption: Bool?
    var ferriesOption: Bool?
    var uturnsOption: Bool?
    var tunnelsOption: Bool?
    var dirtRoadsOption: Bool?
    
    func updateViews(tollOption: Bool, ferriesOption: Bool, uturnsOption: Bool, tunnelsOption: Bool, dirtRoadsOption: Bool) {
        self.tollOption = tollOption
        self.ferriesOption = ferriesOption
        self.uturnsOption = uturnsOption
        self.tunnelsOption = tunnelsOption
        self.dirtRoadsOption = dirtRoadsOption
    }
    
    

    
    func updateViews(tollOption: Bool, ferriesOption: Bool) {

    }
    
}
