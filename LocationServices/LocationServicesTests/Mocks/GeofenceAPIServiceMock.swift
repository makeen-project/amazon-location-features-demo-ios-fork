//
//  GeofenceAPIServiceMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
@testable import LocationServices

class GeofenceAPIServiceMock: GeofenceServiceable {
    var mockPutGeofenceResult: Result<GeofenceDataModel, Error> = .success(GeofenceDataModel(id: "test", lat: 0.0, long: 0.0, radius: 100))
    var mockDeleteGeofenceResult: Result<String, Error> = .success("")
    var mockGetGeofenceListResult: Result<[GeofenceDataModel], Error> = .success([GeofenceDataModel(id: "test", lat: 0.0, long: 0.0, radius: 100)])
    var mockEvaluateGeofenceResult: Result<Void, Error> = .success(())
    
    let delay: TimeInterval
        
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func putGeofence(with id: String, lat: Double, long: Double, radius: Double) async -> Result<GeofenceDataModel, Error> {
        return mockPutGeofenceResult
    }
    
    func deleteGeofence(with id: String) async -> Result<String, Error> {
        return mockDeleteGeofenceResult
    }
    
    func getGeofenceList() async -> Result<[GeofenceDataModel], Error> {
        return mockGetGeofenceListResult
    }
    
    func evaluateGeofence(lat: Double, long: Double) async throws {
        switch mockEvaluateGeofenceResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}
