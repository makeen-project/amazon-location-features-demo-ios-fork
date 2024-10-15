//
//  GeofenceUITests.swift
//  GeofenceUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

final class GeofenceUITests: LocationServicesUITests {
    
    enum Constants {
        static let geofenceName = "testgeo"
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
    }
}
