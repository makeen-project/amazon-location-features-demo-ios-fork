//
//  TrackingService.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocationXCF
import CoreLocation

private enum TrackingServiceConstant {
    static let collectionName = "location.aws.com.demo.trackers.Tracker"
    static let deviceId = UIDevice.current.identifierForVendor!.uuidString
}

protocol AWSTrackingServiceProtocol {
    func sendUserLocation(lat: Double, long: Double, completion: @escaping  (Result<AWSLocationBatchUpdateDevicePositionResponse, Error>) -> Void)
    func getTrackingHistory(completion: @escaping (Result<AWSLocationGetDevicePositionHistoryResponse, Error>) -> Void)
}

extension AWSTrackingServiceProtocol {
    func sendUserLocation(lat: Double, long: Double, completion: @escaping  (Result<AWSLocationBatchUpdateDevicePositionResponse, Error>) -> Void) {
        
        let request = AWSLocationBatchUpdateDevicePositionRequest()!
        request.trackerName = TrackingServiceConstant.collectionName
        let devicePositionUpdate = AWSLocationDevicePositionUpdate()
        
        devicePositionUpdate?.deviceId = TrackingServiceConstant.deviceId
        devicePositionUpdate?.position = [NSNumber(value: lat), NSNumber(value: long)]
        devicePositionUpdate?.sampleTime = Date()
       
        request.updates = Array(arrayLiteral: devicePositionUpdate!)
        
        let result = AWSLocation(forKey: "default").batchUpdateDevicePosition(request)
        
        result.continueWith { response in
            if let taskResult = response.result {
                completion(.success(taskResult))
            } else {
                let defaultError = NSError(domain: "Tracking", code: -1)
                let error = response.error ?? defaultError
                print("error \(error)")
                completion(.failure(error))
            }
            
            return nil
        }
    }
    
    func getTrackingHistory(completion: @escaping  (Result<AWSLocationGetDevicePositionHistoryResponse, Error>) -> Void) {
        let request = AWSLocationGetDevicePositionHistoryRequest()!
        request.trackerName = TrackingServiceConstant.collectionName
        request.deviceId = TrackingServiceConstant.deviceId
        
        let result = AWSLocation(forKey: "default").getDevicePositionHistory(request)
        
        result.continueWith { response in
            if let taskResult = response.result {
                completion(.success(taskResult))
            } else {
                let defaultError = NSError(domain: "Tracking", code: -1)
                let error = response.error ?? defaultError
                print("error \(error)")
                completion(.failure(error))
            }
            return nil
        }
    }
    
    func removeAllHistory(completion: @escaping  (Result<Void, Error>) -> Void) {
        let request = AWSLocationBatchDeleteDevicePositionHistoryRequest()!
        request.deviceIds = [TrackingServiceConstant.deviceId]
        request.trackerName = TrackingServiceConstant.collectionName
        
        let result = AWSLocation(forKey: "default").batchDeleteDevicePositionHistory(request)
        
        result.continueWith { response in
            if response.result != nil {
                completion(.success(()))
            } else {
                let defaultError = NSError(domain: "Tracking", code: -1)
                let error = response.error ?? defaultError
                print("error \(error)")
                completion(.failure(error))
            }
            return nil
        }
    }
}
