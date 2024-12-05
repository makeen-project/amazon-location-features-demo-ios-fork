//
//  SearchCellViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSGeoPlaces

enum SearchType {
    case location, search, mylocation
}

struct SearchCellViewModel {
    let searchType: SearchType
    let placeId: String?
    let locationName: String?
    let locationDistance: Double?
    let locationCountry: String?
    let locationCity: String?
    let label: String?
    let long: Double?
    let lat: Double?
    let queryId: String?
    let queryType: GeoPlacesClientTypes.QueryType?
    
    init(model: SearchPresentation) {
        self.placeId = model.placeId
        self.locationName = model.name
        self.locationDistance = model.distance
        self.locationCountry = model.countryName
        self.locationCity = model.cityName
        self.label = model.fullLocationAddress
        self.lat = model.placeLat
        self.long = model.placeLong

        if placeId == "myLocation" {
            self.searchType = .mylocation
        } else if model.suggestType == .place {
            self.searchType = .location
        } else {
            self.searchType = .search
        }
        self.queryType = model.queryType
        self.queryId = model.queryId
    }
    
    init(searchType: SearchType,
         placeId: String?,
         locationName: String?,
         locationDistance: Double?,
         locationCountry: String?,
         locationCity: String?,
         label: String?,
         long: Double?,
         lat: Double?,
         queryId: String?,
         queryType: GeoPlacesClientTypes.QueryType?) {
        self.searchType = searchType
        self.placeId = placeId
        self.locationName = locationName
        self.locationDistance = locationDistance
        self.locationCountry = locationCountry
        self.locationCity = locationCity
        self.label = label
        self.long = long
        self.lat = lat
        self.queryType = queryType
        self.queryId = queryId
    }
}
