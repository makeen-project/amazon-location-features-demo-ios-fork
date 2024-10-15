//
//  TrackingServiceable.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocation

protocol TrackingServiceable {
    func updateTrackerLocation(lat: Double, long: Double) async throws -> BatchUpdateDevicePositionOutput
    func getAllTrackingHistory() async throws -> [TrackingHistoryPresentation]
}

struct TrackingAPIService: AWSTrackingServiceProtocol, TrackingServiceable {
    
    func updateTrackerLocation(lat: Double, long: Double) async throws -> BatchUpdateDevicePositionOutput {
        let result = try await sendUserLocation(lat: lat, long: long)
        return result!
    }
    
    func getAllTrackingHistory() async throws -> [TrackingHistoryPresentation]  {
        let result = try await getTrackingHistory()
        if let positions = result {
            let sortedPositions = positions.sorted { (position1, position2) -> Bool in
                let timestamp1 = position1.sampleTime ?? Date()
                let timestamp2 = position2.sampleTime ?? Date()
                
                return timestamp1 > timestamp2
            }
            let presentation = sortedPositions.map { TrackingHistoryPresentation(model: $0,
                                stepType: sortedPositions.last?.sampleTime == $0.sampleTime ? .last : .first) }
            return presentation
        }
        return []
    }
}
