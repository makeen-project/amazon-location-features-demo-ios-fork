//
//  CLLocationCoordinate2DExtensionTests.swift
//  CLLocationCoordinate2DExtensionTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices
import CoreLocation

final class CLLocationCoordinate2DExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDistanceWithZeroDistance() throws {
        let location = CLLocationCoordinate2D(latitude: 40.75790965683081, longitude: -73.98559624758715)
        let distance = location.distance(from: location) // same location for zero distance
        XCTAssertEqual(distance, 0, "Expected 0 distance")
    }
    
    func testDistance() throws {
        let departureLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.75790965683081, longitude: -73.98559624758715)
        let destinationLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:40.75474012009525, longitude: -73.98387963388527)
        let distance = destinationLocation.distance(from: departureLocation) // same location for zero distance
        XCTAssertGreaterThanOrEqual(distance, 380, "Expected 380.65594121226394 distance")
    }

    func testIsSameLocationWithSameDotsAndZeroAccuracy() throws {
        let location = CLLocationCoordinate2D(latitude: 40.75790965683081, longitude: -73.98559624758715)
        let isSame = location.isSameLocation(location)
        XCTAssertEqual(isSame, false, "Expected false")
    }
    
    func testIsSameLocationWithDotsWithinAccuracyCircle() throws {
        let location = CLLocationCoordinate2D(latitude: 40.75790965683081, longitude: -73.98559624758715)
        let isSame = location.isSameLocation(location, accuracy: 100)
        XCTAssertEqual(isSame, true, "Expected true")
    }
    
    func testIsSameLocationWithDotsOutOfAccuracyCircle() throws {
        let location = CLLocationCoordinate2D(latitude: 40.75790965683081, longitude: -73.98559624758715)
        let destinationLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:40.75474012009525, longitude: -73.98387963388527)
        let isSame = location.isSameLocation(destinationLocation, accuracy: 100)
        XCTAssertEqual(isSame, false, "Expected false")
    }
    
    func testIsCurrentLocationWithNilValue() throws {
        let location = CLLocationCoordinate2D(latitude: 40.75790965683081, longitude: -73.98559624758715)
        let isCurrentLocation = location.isCurrentLocation(nil)
        XCTAssertEqual(isCurrentLocation, false, "Expected false")
    }
    
    func testIsCurrentLocationWithCurrenLocationValue() throws {
        let location = CLLocationCoordinate2D(latitude: 40.75790965683081, longitude: -73.98559624758715)
        let destinationLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:40.75474012009525, longitude: -73.98387963388527)
        let isCurrentLocation = location.isCurrentLocation(destinationLocation)
        XCTAssertEqual(isCurrentLocation, false, "Expected false")
    }

    func testConformanceToHashProtocol() throws {
        let location = CLLocationCoordinate2D(latitude: 40.75790965683081, longitude: -73.98559624758715)
        XCTAssertNotEqual(location.hashValue, 0, "Expected has value")
    }
    
    func testLocationWithRadious() throws {
        let location = CLLocationCoordinate2D(latitude: 40.75790965683081, longitude: -73.98559624758715)
        let locationWithRadius = location.location(radius: 50, radians: 0)
        XCTAssertNotEqual(locationWithRadius.latitude, location.latitude, "Expected true")
    }
}
