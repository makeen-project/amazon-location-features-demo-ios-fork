//
//  GeofenceDataModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocationXCF

struct GeofenceDataModel {
    var id: String?
    var lat: Double?
    var long: Double?
    var radius: Int64?
    
    var name: String? {
        return id
    }
    
    init(id: String? = nil,
         lat: Double? = nil,
         long: Double? = nil,
         radius: Int64? = nil) {
        
        self.id = id
        self.lat = lat
        self.long = long
        self.radius = radius
    }
    
    init(model: GeofenceData) {
        self.id = model.id
        self.lat = model.lat
        self.long = model.long
        self.radius = model.radius
    }
    
    init(model: AWSLocationListGeofenceResponseEntry) {
        id = model.geofenceId
        lat = model.geometry?.circle?.center?.last?.doubleValue
        long = model.geometry?.circle?.center?.first?.doubleValue
        radius = model.geometry?.circle?.radius?.int64Value
    }
}
