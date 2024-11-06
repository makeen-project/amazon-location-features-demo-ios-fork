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
        do {
            try await AWSLoginService.default().refreshLoginIfExpired()
            let circle = LocationClientTypes.Circle(center: center, radius: radius)
            let geometry = LocationClientTypes.GeofenceGeometry(circle: circle)
            let input = PutGeofenceInput(collectionName: GeofenceServiceConstant.collectionName, geofenceId: id, geometry: geometry)
            if let client = try await AmazonLocationClient.getCognitoLocationClient() {
                let result = try await client.putGeofence(input: input)
                return result
            } else {
                return nil
            }
        }
        catch {
            throw error
        }
    }
    
    func deleteGeofences(with ids: [String]) async throws -> BatchDeleteGeofenceOutput? {
        do {
            try await AWSLoginService.default().refreshLoginIfExpired()
            let input = BatchDeleteGeofenceInput(collectionName: GeofenceServiceConstant.collectionName, geofenceIds: ids)
            if let client = try await AmazonLocationClient.getCognitoLocationClient() {
                let result = try await client.batchDeleteGeofence(input: input)
                return result
            } else {
                return nil
            }
        }
        catch {
            throw error
        }
    }
    
    func fetchGeofenceList() async throws -> ListGeofencesOutput? {
        do {
            try await AWSLoginService.default().refreshLoginIfExpired()
            let input = ListGeofencesInput(collectionName: GeofenceServiceConstant.collectionName)
            if let client = try await  AmazonLocationClient.getCognitoLocationClient() {
                let result = try await client.listGeofences(input: input)
                return result
            } else {
                return nil
            }
        }
        catch {
            throw error
        }
    }
    
    func batchEvaluateGeofences(lat: Double, long: Double) async throws -> BatchEvaluateGeofencesOutput? {
        do {
            try await AWSLoginService.default().refreshLoginIfExpired()
            var devicePositionUpdate = LocationClientTypes.DevicePositionUpdate(deviceId: GeofenceServiceConstant.deviceId, position: [long, lat], sampleTime: Date())
            
            if let identityId = UserDefaultsHelper.get(for: String.self, key: .signedInIdentityId) {
                print("batchEvaluateGeofences: deviceId: \(GeofenceServiceConstant.deviceId) region: \(identityId.toRegionString()) identity Id: \(identityId.toId())")
                devicePositionUpdate.positionProperties = ["region": identityId.toRegionString(), "id": identityId.toId()]
            }
            let input = BatchEvaluateGeofencesInput(collectionName: GeofenceServiceConstant.collectionName, devicePositionUpdates: [devicePositionUpdate])
            if let client = try await AmazonLocationClient.getCognitoLocationClient() {
                let result = try await client.batchEvaluateGeofences(input: input)
                return result
            } else {
                return nil
            }
        }
        catch {
            throw error
        }
    }
}
