//
//  GeofenceDataModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocation

struct GeofenceDataModel {
    var id: String?
    var lat: Double?
    var long: Double?
    var radius: Double?
    
    var name: String? {
        return id
    }
    
    init(id: String? = nil,
         lat: Double? = nil,
         long: Double? = nil,
         radius: Double? = nil) {
        
        self.id = id
        self.lat = lat
        self.long = long
        self.radius = radius
    }
    
    init(model: GeofenceData) {
        self.id = model.id
        self.lat = model.lat
        self.long = model.long
        self.radius = Double(model.radius)
    }
    
    init(model: LocationClientTypes.ListGeofenceResponseEntry) {
        id = model.geofenceId
        lat = model.geometry?.circle?.center?.last
        long = model.geometry?.circle?.center?.first
        radius = model.geometry?.circle?.radius
    }
}
