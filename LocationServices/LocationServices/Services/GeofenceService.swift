//
//  GeofenceService.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocationXCF
import AWSMobileClientXCF
import CoreLocation


enum GeofenceServiceConstant {
    static let collectionName = "location.aws.com.demo.geofences.GeofenceCollection"
    static let deviceId = UIDevice.current.identifierForVendor!.uuidString
}

protocol AWSGeofenceServiceProtocol {
    func putGeofence(with id: String, center: [Double], radius: Int, completion: @escaping(Result<AWSLocationPutGeofenceResponse, Error>) -> Void)
    func deleteGeofences(with ids: [String], completion: @escaping(Result<AWSLocationBatchDeleteGeofenceResponse, Error>) -> Void)
    func fetchGeofenceList(completion: @escaping (Result<[AWSLocationListGeofenceResponseEntry], Error>)->())
    func batchEvaluateGeofences(lat: Double, long: Double, completion: @escaping(Result<AWSLocationBatchEvaluateGeofencesResponse, Error>) -> Void)
}

extension AWSGeofenceServiceProtocol {
    
    func putGeofence(with id: String, center: [Double], radius: Int, completion: @escaping(Result<AWSLocationPutGeofenceResponse, Error>) -> Void) {
        let request = AWSLocationPutGeofenceRequest()!
        request.collectionName = GeofenceServiceConstant.collectionName

        request.geofenceId = id
        request.geometry = AWSLocationGeofenceGeometry()
        request.geometry?.circle = AWSLocationCircle()
        request.geometry?.circle?.center = center as [NSNumber]
        request.geometry?.circle?.radius = radius as NSNumber
        
        let result = AWSLocation(forKey: "default").putGeofence(request)
        result.continueWith { response in
            if let taskResult = response.result {
                completion(.success(taskResult))
            } else {
                let defaultError = NSError(domain: "Geofence", code: -1)
                let error = response.error ?? defaultError
                print("error \(error)")
                completion(.failure(error))
            }
            
            return nil
        }
    }
    
    func deleteGeofences(with ids: [String], completion: @escaping(Result<AWSLocationBatchDeleteGeofenceResponse, Error>) -> Void) {
        let request = AWSLocationBatchDeleteGeofenceRequest()!
        request.collectionName = GeofenceServiceConstant.collectionName
        request.geofenceIds = ids
        
        let result = AWSLocation(forKey: "default").batchDeleteGeofence(request)
        result.continueWith { response in
            if let taskResult = response.result {
                completion(.success(taskResult))
            } else {
                let defaultError = NSError(domain: "Geofence", code: -1)
                let error = response.error ?? defaultError
                print("error \(error)")
                completion(.failure(error))
            }
            
            return nil
        }
    }
    
    func fetchGeofenceList(completion: @escaping (Result<[AWSLocationListGeofenceResponseEntry], Error>)->()) {
        let request = AWSLocationListGeofencesRequest()!
        request.collectionName = GeofenceServiceConstant.collectionName
    
        let result = AWSLocation(forKey: "default").listGeofences(request)
        
        result.continueWith { response in
            if let error = response.error {
                print("error \(error)")
                completion(.failure(error))
            } else if let taskResult = response.result {
                print("taskResult \(taskResult)")
                completion(.success(taskResult.entries ?? []))
            }
            
            return nil
        }
    }
    
    func batchEvaluateGeofences(lat: Double, long: Double, completion: @escaping(Result<AWSLocationBatchEvaluateGeofencesResponse, Error>) -> Void) {
        let request = AWSLocationBatchEvaluateGeofencesRequest()!
        request.collectionName = GeofenceServiceConstant.collectionName
        
        let devicePositionUpdate = AWSLocationDevicePositionUpdate()!
        devicePositionUpdate.deviceId = GeofenceServiceConstant.deviceId
        devicePositionUpdate.position = [NSNumber(value: long), NSNumber(value: lat)]
        devicePositionUpdate.sampleTime = Date()
        
        if let identityId = AWSMobileClient.default().identityId {
            let region = identityId.toRegionString()
            let id = identityId.toId()
            devicePositionUpdate.positionProperties = ["region": region, "id": id]
        }
        
        request.devicePositionUpdates = Array(arrayLiteral: devicePositionUpdate)
        let result = AWSLocation(forKey: "default").batchEvaluateGeofences(request)
        
        result.continueWith { response in
            if let taskResult = response.result {
                print("Geofence evaluate result: \(taskResult)")
                completion(.success(taskResult))
            } else {
                let defaultError = NSError(domain: "Geofence", code: -1)
                let error = response.error ?? defaultError
                print("error \(error)")
                completion(.failure(error))
            }
            
            return nil
        }
    }
}
