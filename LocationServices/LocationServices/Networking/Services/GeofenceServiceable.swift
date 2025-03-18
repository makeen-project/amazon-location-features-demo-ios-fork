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
    func putGeofence(with id: String, lat: Double, long: Double, radius: Double) async -> Result<GeofenceDataModel,  Error>
    func deleteGeofence(with id: String) async -> Result<String, Error>
    func getGeofenceList(collectionName: String) async -> Result<[GeofenceDataModel], Error>
    func evaluateGeofence(lat: Double, long: Double) async throws
}

struct GeofenceAPIService: AWSGeofenceServiceProtocol, GeofenceServiceable {
    
    func putGeofence(with id: String, lat: Double, long: Double, radius: Double) async -> Result<GeofenceDataModel,  Error> {
        do {
            let result = try await putGeofence(with: id, center: [long, lat], radius: radius)
            let model = GeofenceDataModel(id: result!.geofenceId, lat: lat, long: long, radius: radius)
             return .success(model)
        }
        catch {
            return .failure(error)
        }
    }
    
    func deleteGeofence(with id: String) async -> Result<String, Error> {
        do {
            let result = try await deleteGeofences(with: [id])
            if let error = result!.errors?.first {
                return .failure(GeofenceError.deleteGeofence(error.error!.message!))
            }
            else {
                return .success("")
            }
        }
        catch {
            return .failure(error)
        }
    }
    
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
    
    func evaluateGeofence(lat: Double, long: Double) async throws {
        let _ = try await batchEvaluateGeofences(lat: lat, long: long)
    }
}
