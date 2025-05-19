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
import AWSCognitoIdentity
import AmazonLocationiOSAuthSDK


enum GeofenceServiceConstant {
    static let collectionName = "GeofenceCollection"
    static let collectionNamePrefix = "location.aws.com.demo.geofences."
    static let deviceId = "iOS-\(UIDevice.current.identifierForVendor!.uuidString)"
}

protocol AWSGeofenceServiceProtocol {
    func fetchGeofenceList(collectionName: String) async throws -> ListGeofencesOutput?
    func batchEvaluateGeofences(lat: Double, long: Double, collectionName: String) async throws -> BatchEvaluateGeofencesOutput?
}

extension AWSGeofenceServiceProtocol {
    func fetchGeofenceList(collectionName: String) async throws -> ListGeofencesOutput? {
        do {
            if let client = CognitoAuthHelper.default().locationClient {
                let input = ListGeofencesInput(collectionName: "\(GeofenceServiceConstant.collectionNamePrefix)\(collectionName)")
                let result = try await client.listGeofences(input: input)
                return result
            } else {
                return nil
            }
        }
        catch {
            print(error)
            throw error
        }
    }
    
    func batchEvaluateGeofences(lat: Double, long: Double, collectionName: String) async throws -> BatchEvaluateGeofencesOutput? {
        do {
            var devicePositionUpdate = LocationClientTypes.DevicePositionUpdate(deviceId: GeofenceServiceConstant.deviceId, position: [long, lat], sampleTime: Date())
            
            if let identityId = UserDefaultsHelper.get(for: String.self, key: .identityId) {
                print("batchEvaluateGeofences: deviceId: \(GeofenceServiceConstant.deviceId) region: \(identityId.toRegionString()) identity Id: \(identityId.toId())")
                devicePositionUpdate.positionProperties = ["region": identityId.toRegionString(), "id": identityId.toId()]
            }
            let input = BatchEvaluateGeofencesInput(collectionName: "\(GeofenceServiceConstant.collectionNamePrefix)\(collectionName)", devicePositionUpdates: [devicePositionUpdate])
            if let client = CognitoAuthHelper.default().locationClient {
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
