//
//  GeofenceDataModel+Extension.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

extension GeofenceDataModel {
    func compare(id: String? = nil, lat: Double? = nil, long: Double? = nil, radius: Int? = nil) {
        if let id {
            XCTAssertEqual(self.id, id)
        }
        if let lat {
            XCTAssertEqual(self.lat, lat)
        }
        if let long {
            XCTAssertEqual(self.long, long)
        }
        if let radius {
            XCTAssertEqual(self.radius, Int64(radius))
        }
    }
}
