//
//  MapModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

struct MapModel {
    let placeId: String?
    let placeName: String?
    let placeAddress: String?
    let placeCity: String?
    let placeCountry: String?
    let placeLat: Double?
    let placeLong: Double?
    var distance: Double?
    var duration: String?
    
    init(placeId: String? = nil, placeName: String? = nil, placeAddress: String? = nil, placeCity: String? = nil, placeCountry: String? = nil, placeLat: Double? = nil, placeLong: Double? = nil, distance: Double? = nil, duration: String? = nil) {
        self.placeId = placeId
        self.placeName = placeName
        self.placeAddress = placeAddress
        self.placeCity = placeCity
        self.placeCountry = placeCountry
        self.placeLat = placeLat
        self.placeLong = placeLong
        self.distance = distance
        self.duration = duration
    }
    
    init(model: SearchPresentation) {
        self.placeId = model.placeId
        self.placeName = model.name
        self.placeAddress = model.fullLocationAddress
        self.placeCity = model.cityName
        self.placeCountry = model.countryName
        self.placeLat = model.placeLat
        self.placeLong = model.placeLong
        self.distance = model.distance
        self.duration = nil
    }
}
