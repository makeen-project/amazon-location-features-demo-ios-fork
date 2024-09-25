//
//  TrackingService.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocation
import CoreLocation
import UIKit

private enum TrackingServiceConstant {
    static let collectionName = "location.aws.com.demo.trackers.Tracker"
    static let deviceId = UIDevice.current.identifierForVendor!.uuidString
}

protocol AWSTrackingServiceProtocol {
    func sendUserLocation(lat: Double, long: Double) async throws -> BatchUpdateDevicePositionOutput?
    func getTrackingHistory(nextToken: String?) async throws -> [LocationClientTypes.DevicePosition]?
    func removeAllHistory() async throws -> BatchDeleteDevicePositionHistoryOutput?
}

extension AWSTrackingServiceProtocol {
    func sendUserLocation(lat: Double, long: Double) async throws -> BatchUpdateDevicePositionOutput? {
        do {
            try await AWSLoginService.default().refreshLoginIfExpired()
            let devicePositionUpdate = LocationClientTypes.DevicePositionUpdate(deviceId: TrackingServiceConstant.deviceId, position: [long, lat], sampleTime: Date())
            let devicePositionUpdates: [LocationClientTypes.DevicePositionUpdate]? = [devicePositionUpdate]
            
            let input = BatchUpdateDevicePositionInput(trackerName: TrackingServiceConstant.collectionName, updates: devicePositionUpdates)
            if let client = try await AmazonLocationClient.defaultCognito()?.locationClient {
                let result = try await client.batchUpdateDevicePosition(input: input)
                return result
            } else {
                return nil
            }
        }
        catch {
            throw error
        }
    }
    
    func getTrackingHistory(nextToken: String? = nil) async throws -> [LocationClientTypes.DevicePosition]? {
        do {
            try await AWSLoginService.default().refreshLoginIfExpired()
            let input = GetDevicePositionHistoryInput(deviceId: TrackingServiceConstant.deviceId, nextToken: nextToken, trackerName: TrackingServiceConstant.collectionName)
            if let client = try await AmazonLocationClient.defaultCognito()?.locationClient {
                let result = try await client.getDevicePositionHistory(input: input)
                var devicePositions = result.devicePositions ?? []
                
                if let nextToken = result.nextToken {
                    devicePositions += try await self.getTrackingHistory(nextToken: nextToken) ?? []
                }
                return devicePositions
            } else {
                return nil
            }
        }
        catch {
            throw error
        }
    }
    
    func removeAllHistory() async throws -> BatchDeleteDevicePositionHistoryOutput? {
        do {
            try await AWSLoginService.default().refreshLoginIfExpired()
            let input = BatchDeleteDevicePositionHistoryInput(deviceIds: [TrackingServiceConstant.deviceId], trackerName: TrackingServiceConstant.collectionName)
            if let client = try await AmazonLocationClient.defaultCognito()?.locationClient {
                let result = try await client.batchDeleteDevicePositionHistory(input: input)
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
