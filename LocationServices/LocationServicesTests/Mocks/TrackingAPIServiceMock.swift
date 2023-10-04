//
//  TrackingAPIServiceMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
@testable import LocationServices

class TrackingAPIServiceMock: TrackingServiceable {
    var putResult: Result<Void, Error>?
    var deleteResult: Result<String, Error>?
    var getResult: Result<[TrackingHistoryPresentation], Error>?
    
    let delay: TimeInterval
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func updateTrackerLocation(lat: Double, long: Double, completion: @escaping (Result<Void, Error>) -> ()) {
        perform { [weak self] in
            guard let result = self?.putResult else { return }
            completion(result)
        }
    }
    
    func getAllTrackingHistory(completion: @escaping (Result<[LocationServices.TrackingHistoryPresentation], Error>) -> Void) {
        perform { [weak self] in
            guard let result = self?.getResult else { return }
            completion(result)
        }
    }
    
    
    private func perform(action: @escaping ()->()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            action()
        }
    }
}

