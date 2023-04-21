//
//  GeofenceAPIServiceMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
@testable import LocationServices

class GeofenceAPIServiceMock: GeofenceServiceable {
    var itemResult: Result<GeofenceDataModel, Error>?
    var stringResult: Result<String, Error>?
    var arrayResult: Result<[GeofenceDataModel], Error>?
    
    let delay: TimeInterval
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func putGeofence(with id: String, lat: Double, long: Double, radius: Int, completion: @escaping (Result<GeofenceDataModel, Error>) -> Void) {
        perform { [weak self] in
            guard let result = self?.itemResult else { return }
            completion(result)
        }
    }
    
    func deleteGeofence(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        perform { [weak self] in
            guard let result = self?.stringResult else { return }
            completion(result)
        }
    }
    
    func getGeofenceList(completion: @escaping (Result<[GeofenceDataModel], Error>) -> ()) {
        perform { [weak self] in
            guard let result = self?.arrayResult else { return }
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
