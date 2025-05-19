//
//  GeofenceAPIServiceMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
@testable import LocationServices

class GeofenceAPIServiceMock: GeofenceServiceable {
    func getGeofenceList(collectionName: String) async -> Result<[LocationServices.GeofenceDataModel], any Error> {
        return mockGetGeofenceListResult
    }
    
    func evaluateGeofence(lat: Double, long: Double, collectionName: String) async throws {
        switch mockEvaluateGeofenceResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    var mockGetGeofenceListResult: Result<[GeofenceDataModel], Error> = .success([GeofenceDataModel(id: "test", lat: 0.0, long: 0.0, radius: 100)])
    var mockEvaluateGeofenceResult: Result<Void, Error> = .success(())
    
    let delay: TimeInterval
        
    init(delay: TimeInterval) {
        self.delay = delay
    }
}
