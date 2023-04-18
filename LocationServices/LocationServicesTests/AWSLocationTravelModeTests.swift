//
//  AWSLocationTravelMode.swift
//  LocationServicesTests
//
//  Created by Zeeshan Sheikh on 17/04/2023.
//

import XCTest
@testable import LocationServices
import AWSLocationXCF

final class AWSLocationTravelModeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitWithWalking() throws {
        let travelMode = AWSLocationTravelMode(routeType: .walking)
        XCTAssertEqual(travelMode, .walking, "Route mode Waking expected")
    }
    
    func testInitWithCar() throws {
        let travelMode = AWSLocationTravelMode(routeType: .car)
        XCTAssertEqual(travelMode, .car, "Route mode Car expected")
    }
    
    func testInitWithTruck() throws {
        let travelMode = AWSLocationTravelMode(routeType: .truck)
        XCTAssertEqual(travelMode, .truck, "Route mode Waking expected")
    }

}
