//
//  SettingsDefaultValueHelper.swift
//  LocationServicesTests
//
//  Created by Zeeshan Sheikh on 12/04/2023.
//

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
    }
    
    func testCreateDefaulValuesWithStorage() throws {
        let settingsDefaultValueHelper: SettingsDefaultValueHelper = SettingsDefaultValueHelper()
        settingsDefaultValueHelper.createValues()
        settingsDefaultValueHelper.createValues()
    }

}
