//
//  GeofenceAPIServiceMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
@testable import LocationServices

class GeofenceAPIServiceMock: GeofenceServiceable {
    var putResult: Result<GeofenceDataModel, Error>?
    var deleteResult: Result<String, Error>?
    var getResult: Result<[GeofenceDataModel], Error>?
    
    let delay: TimeInterval
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func putGeofence(with id: String, lat: Double, long: Double, radius: Int, completion: @escaping (Result<GeofenceDataModel, Error>) -> Void) {
        perform { [weak self] in
            guard let result = self?.putResult else { return }
            completion(result)
        }
    }
    
    func deleteGeofence(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        perform { [weak self] in
            guard let result = self?.deleteResult else { return }
            completion(result)
        }
    }
    
    func getGeofenceList(completion: @escaping (Result<[GeofenceDataModel], Error>) -> ()) {
        perform { [weak self] in
            guard let result = self?.getResult else { return }
            completion(result)
        }
    }
    
    func evaluateGeofence(lat: Double, long: Double) {
    }
    
    private func perform(action: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            action()
        }
    }
}
