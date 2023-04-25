//
//  MGLCoordinateBoundsExtensionTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices
import CoreLocation
import Mapbox

final class MGLCoordinateBoundsExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCreateWithEmptyArray() throws {
        let coordinateBounds = MGLCoordinateBounds.create(from: [])
        XCTAssertEqual(coordinateBounds.ne.latitude.formatted(), "0", "Coordinate Bounds latitude matched")
    }
    
    func testCreateWithOneValueInArray() throws {
        let departureLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.75790965683081, longitude: -73.98559624758715)
        let coordinateBounds = MGLCoordinateBounds.create(from: [departureLocation])
        XCTAssertEqual(coordinateBounds.ne.longitude.formatted(), "-73.985596", "Coordinate Bounds longitude matched")
    }
    

    func testCreateWithCoordinates() throws {
        let departureLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.75790965683081, longitude: -73.98559624758715)
        let destinationLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:40.75474012009525, longitude: -73.98387963388527)
        let coordinateBounds = MGLCoordinateBounds.create(from: [departureLocation, destinationLocation])
        XCTAssertEqual(coordinateBounds.ne.latitude.formatted(), "40.75791", "Coordinate Bounds latitude matched")
    }

}
