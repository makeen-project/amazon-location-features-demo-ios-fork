//
//  GeofenceServiceable.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSLocation


enum GeofenceError: Error {
    case deleteGeofence(String)
    case listGeofence(String)
}

protocol GeofenceServiceable {
    func getGeofenceList(collectionName: String) async -> Result<[GeofenceDataModel], Error>
    func evaluateGeofence(lat: Double, long: Double, collectionName: String) async throws
}

struct GeofenceAPIService: AWSGeofenceServiceProtocol, GeofenceServiceable {
    
    func getGeofenceList(collectionName: String) async -> Result<[GeofenceDataModel], Error> {
        do {
            let result = try await fetchGeofenceList(collectionName: collectionName)
            if result != nil {
                let models = result!.entries!.map( { GeofenceDataModel(model: $0) })
                return .success(models)
            }
            else {
                return .failure(GeofenceError.listGeofence("No geofence founc"))
            }
        }
        catch {
            return .failure(error)
        }
    }
    
    func evaluateGeofence(lat: Double, long: Double, collectionName: String) async throws {
        let _ = try await batchEvaluateGeofences(lat: lat, long: long, collectionName: collectionName)
    }
}
