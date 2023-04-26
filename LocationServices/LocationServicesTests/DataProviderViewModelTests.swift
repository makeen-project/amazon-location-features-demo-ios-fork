//
//  DataProviderViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class DataProviderViewModelTests: XCTestCase {

    let dataProviderViewModel = DataProviderViewModel()
    
    override func setUpWithError() throws {
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetItemCount() throws {
        XCTAssertEqual(dataProviderViewModel.getItemCount(), 2, "Expected count")
    }
    
    func testGetItemFor() throws {
        let indexPath = IndexPath(row: 0, section: 0)
        XCTAssertEqual(dataProviderViewModel.getItemFor(indexPath).title, "Esri", "Expected count")
    }
    
    func testSaveSelectedState() throws {
        let indexPath = IndexPath(row: 0, section: 0)
        dataProviderViewModel.saveSelectedState(indexPath)
        let obj = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        XCTAssertEqual(obj?.title, "Light", "Expected saved selected state")
        
    }
    
    func testLoadData() throws {
        let indexPath = IndexPath(row: 0, section: 0)
        dataProviderViewModel.saveSelectedState(indexPath)
        dataProviderViewModel.loadData()
        let obj = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        XCTAssertEqual(obj?.title, "Light", "Expected saved selected state")
    }

}
