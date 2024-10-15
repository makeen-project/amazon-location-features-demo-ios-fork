//
//  TrackingAPIServiceMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
@testable import LocationServices
import AWSLocation
import AWSLocation

class TrackingAPIServiceMock: TrackingServiceable {
    var mockUpdateTrackerLocationResult: Result<BatchUpdateDevicePositionOutput, Error> = .success(BatchUpdateDevicePositionOutput())
    var mockGetAllTrackingHistoryResult: Result<[TrackingHistoryPresentation], Error> = .success([])
        
    let delay: TimeInterval
        
    init(delay: TimeInterval) {
        self.delay = delay
    }
    func updateTrackerLocation(lat: Double, long: Double) async throws -> BatchUpdateDevicePositionOutput {
        switch mockUpdateTrackerLocationResult {
        case .success(let output):
            return output
        case .failure(let error):
            throw error
        }
    }
    
    func getAllTrackingHistory() async throws -> [TrackingHistoryPresentation] {
        switch mockGetAllTrackingHistoryResult {
        case .success(let history):
            return history
        case .failure(let error):
            throw error
        }
    }
}

