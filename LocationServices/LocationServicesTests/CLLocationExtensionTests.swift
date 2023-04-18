//
//  CLLocationExtension.swift
//  LocationServicesTests
//
//  Created by Zeeshan Sheikh on 17/04/2023.
//

import XCTest
@testable import LocationServices
import CoreLocation

final class CLLocationExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInit() throws {
        let location = CLLocation.init(latitude: 40.75790965683081, longitude: -73.98559624758715)
        XCTAssertNotEqual(location.coordinate, nil, "CLLocation init not nil")
    }

}
