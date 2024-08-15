//
//  MapModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

struct MapModel {
    let placeName: String?
    let placeAddress: String?
    let placeLat: Double?
    let placeLong: Double?
    var distance: Double?
    var duration: String?
    
    init(placeName: String? = nil, placeAddress: String? = nil, placeLat: Double? = nil, placeLong: Double? = nil, distance: Double? = nil, duration: String? = nil) {
        self.placeName = placeName
        self.placeAddress = placeAddress
        self.placeLat = placeLat
        self.placeLong = placeLong
        self.distance = distance
        self.duration = duration
    }
    
    init(model: SearchPresentation) {
        self.placeName = model.name
        self.placeAddress = model.fullLocationAddress
        self.placeLat = model.placeLat
        self.placeLong = model.placeLong
        self.distance = model.distance
        self.duration = nil
    }
}
