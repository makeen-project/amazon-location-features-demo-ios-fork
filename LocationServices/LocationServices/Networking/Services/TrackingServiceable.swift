//
//  TrackingServiceable.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocationXCF

protocol TrackingServiceable {
    func updateTrackerLocation(lat: Double, long: Double, completion: @escaping (Result<Void, Error>)->())
    func getAllTrackingHistory(completion: @escaping (Result<[TrackingHistoryPresentation], Error>) -> Void)
}

struct TrackingAPIService: AWSTrackingServiceProtocol, TrackingServiceable {
    
    func updateTrackerLocation(lat: Double, long: Double, completion: @escaping (Result<Void, Error>)->()) {
        sendUserLocation(lat: lat, long: long) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getAllTrackingHistory(completion: @escaping (Result<[TrackingHistoryPresentation], Error>) -> Void) {
        getTrackingHistory { result in
            
            switch result {
            case .success(let response):
                let positions = response.devicePositions ?? []
                let sortedPositions = positions.sorted { (position1, position2) -> Bool in
                    let timestamp1 = position1.sampleTime ?? Date()
                    let timestamp2 = position2.sampleTime ?? Date()
                    
                    return timestamp1 > timestamp2
                }
                let presentation = sortedPositions.map { TrackingHistoryPresentation(model: $0,
                                                                               stepType: sortedPositions.last == $0 ? .last : .first) }
                completion(.success(presentation))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
