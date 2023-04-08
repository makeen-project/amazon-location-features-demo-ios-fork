//
//  GeofenceServiceable.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSLocationXCF


protocol GeofenceServiceable {
    func putGeofence(with id: String, lat: Double, long: Double, radius: Int, completion: @escaping(Result<GeofenceDataModel, Error>) -> Void)
}

struct GeofenceAPIService: AWSGeofenceServiceProtocol, GeofenceServiceable {
    
    func putGeofence(with id: String, lat: Double, long: Double, radius: Int, completion: @escaping(Result<GeofenceDataModel, Error>) -> Void) {
        putGeofence(with: id, center: [long, lat], radius: radius) { result in
            switch result {
            case .success(let response):
                let model = GeofenceDataModel(id: response.geofenceId, lat: lat, long: long, radius: Int64(radius))
                completion(.success(model))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteGeofence(with id: String, completion: @escaping(Result<String, Error>) -> Void) {
        deleteGeofences(with: [id]) { result in
            switch result {
            case .success(let response):
                if let errors = response.errors,
                   let error = errors.first(where: { $0.geofenceId == id }) {
                    print(.errorDelegeGeofence + " \(error)")
                    let defaultError = NSError(domain: StringConstant.geofence, code: -1)
                    DispatchQueue.main.async {
                        completion(.failure(defaultError))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.success(id))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getGeofenceList(completion: @escaping (Result<[GeofenceDataModel], Error>)->()) {
        fetchGeofenceList { result in
            switch result {
            case .success(let entries):
                let models = entries.map({ GeofenceDataModel(model: $0) })
                DispatchQueue.main.async {
                    completion(.success(models))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func evaluateGeofence(lat: Double, long: Double) {
        batchEvaluateGeofences(lat: lat, long: long, completion: {_ in
            //TODO: do nothing for now, probably will be used for notifications
        })
    }
}
