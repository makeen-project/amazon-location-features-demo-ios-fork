//
//  GeofenceService.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocation
import CoreLocation
import UIKit


enum GeofenceServiceConstant {
    static let collectionName = "location.aws.com.demo.geofences.GeofenceCollection"
    static let deviceId = UIDevice.current.identifierForVendor!.uuidString
}

protocol AWSGeofenceServiceProtocol {
    func putGeofence(with id: String, center: [Double], radius: Double) async throws -> PutGeofenceOutput?
    func deleteGeofences(with ids: [String]) async throws -> BatchDeleteGeofenceOutput?
    func fetchGeofenceList() async throws -> ListGeofencesOutput?
    func batchEvaluateGeofences(lat: Double, long: Double) async throws -> BatchEvaluateGeofencesOutput?
}

extension AWSGeofenceServiceProtocol {
    
    func putGeofence(with id: String, center: [Double], radius: Double) async throws -> PutGeofenceOutput? {
        let circle = LocationClientTypes.Circle(center: center, radius: radius)
        let geometry = LocationClientTypes.GeofenceGeometry(circle: circle)
        let input = PutGeofenceInput(collectionName: GeofenceServiceConstant.collectionName, geofenceId: id, geometry: geometry)
        if let client = AmazonLocationClient.defaultCognito()?.locationClient {
            let result = try await client.putGeofence(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func deleteGeofences(with ids: [String]) async throws -> BatchDeleteGeofenceOutput? {
        let input = BatchDeleteGeofenceInput(collectionName: GeofenceServiceConstant.collectionName, geofenceIds: ids)
        if let client = AmazonLocationClient.defaultCognito()?.locationClient {
            let result = try await client.batchDeleteGeofence(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func fetchGeofenceList() async throws -> ListGeofencesOutput? {
        let input = ListGeofencesInput(collectionName: GeofenceServiceConstant.collectionName)
        if let client = AmazonLocationClient.defaultCognito()?.locationClient {
            let result = try await client.listGeofences(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func batchEvaluateGeofences(lat: Double, long: Double) async throws -> BatchEvaluateGeofencesOutput? {
        let devicePositionUpdate = LocationClientTypes.DevicePositionUpdate(deviceId: GeofenceServiceConstant.deviceId, position: [long, lat], sampleTime: Date())
        let input = BatchEvaluateGeofencesInput(collectionName: GeofenceServiceConstant.collectionName, devicePositionUpdates: [devicePositionUpdate])
        
//        if let identityId = AmazonLocationClient.default().identityId {
//            let region = identityId.toRegionString()
//            let id = identityId.toId()
//            devicePositionUpdate.positionProperties = ["region": region, "id": id]
//        }
        if let client = AmazonLocationClient.defaultCognito()?.locationClient {
            let result = try await client.batchEvaluateGeofences(input: input)
            return result
        } else {
            return nil
        }
    }
}
