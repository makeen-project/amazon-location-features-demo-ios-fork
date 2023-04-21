//
//  MapStyleViewModelTests.swift
//  MapStyleViewModelTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class MapStyleViewModelTests: XCTestCase {

    let mapStyleViewModel = MapStyleViewModel()
    
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

    func testGetSectionsCount() throws {
       XCTAssertEqual(mapStyleViewModel.getSectionsCount(), 2, "Expected sections count")
    }
    
    func testGetSectionTitle() throws {
        XCTAssertEqual(mapStyleViewModel.getSectionTitle(at: 0), "Esri", "Expected section title")
    }

    func testGetItemCount() throws {
        XCTAssertEqual(mapStyleViewModel.getItemCount(at: 0), 6, "Expected item count")
    }
    
    func testGetCellItems() throws {
        let indexPath = IndexPath(row: 1, section: 0)
        let item = mapStyleViewModel.getCellItem(indexPath)
                
        XCTAssertEqual(item?.title, "Streets", "Expected cell item title")
    }
    
    func testSaveSelectedState() throws {
        let indexPath = IndexPath(row: 1, section: 0)
        mapStyleViewModel.saveSelectedState(indexPath)
        let obj = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        XCTAssertEqual(obj?.title, "Streets", "Expected saved selected state")
        
    }
    
    func testLoadLocalMapData() {
        let indexPath = IndexPath(row: 2, section: 0)
        mapStyleViewModel.saveSelectedState(indexPath)
        mapStyleViewModel.loadLocalMapData()
        let obj = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        XCTAssertEqual(obj?.title, "Navigation", "Expected saved selected state")
    }

}
