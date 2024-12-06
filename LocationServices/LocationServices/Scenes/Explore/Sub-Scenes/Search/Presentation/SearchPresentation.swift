//
//  SearchPresentation.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSGeoPlaces
import CoreLocation


struct SearchPresentation {
    let placeId: String?
    let fullLocationAddress: String?
    let distance: Double?
    let countryName: String?
    let cityName: String?
    let placeLat: Double?
    let placeLong: Double?
    let name: String?
    let placeLabel: String?
    var place: GetPlaceOutput? = nil
    let placeType: GeoPlacesClientTypes.PlaceType?
    let queryType: GeoPlacesClientTypes.QueryType?
    let suggestType: GeoPlacesClientTypes.SuggestResultItemType?
    let queryId: String?
    
    init( placeId: String?,
          fullLocationAddress: String?,
          distance: Double?,
          countryName: String?,
          cityName: String?,
          placeLat: Double?,
          placeLong: Double?,
          name: String?) {
        
        self.placeId = placeId
        self.fullLocationAddress = fullLocationAddress
        self.distance = distance
        self.countryName = countryName
        self.cityName = cityName
        self.placeLat = placeLat
        self.placeLong = placeLong
        self.name = name
        self.placeLabel = fullLocationAddress
        self.placeType = .none
        self.queryType = .none
        self.suggestType = .none
        self.queryId = nil
    }
    
    init(placeId: String, model: GetPlaceOutput) {
        self.placeId = placeId
        self.countryName = model.address?.country?.name
        if let fullAddress = model.address?.label?.formatAddressField() {
            self.name = fullAddress[safe: 0] ?? ""
            self.fullLocationAddress = fullAddress[safe: 1] ?? ""
        } else {
            self.name = nil
            self.fullLocationAddress = nil
        }
        self.distance = 0  //No user location is determined by the app this constructor will be called
        if let point = model.position {
            self.placeLong = point[0]
            self.placeLat = point[1]
        } else {
            self.placeLong = nil
            self.placeLat = nil
        }
        self.cityName = model.address?.district
        self.placeLabel = model.address?.label
        self.placeType = model.placeType
        self.suggestType = .none
        self.queryType = .none
        self.queryId = nil
    }
    
    init(model: GeoPlacesClientTypes.SearchTextResultItem, placeLat: Double? = nil, placeLong: Double? = nil, userLocation: CLLocation? = nil) {
        self.placeId = model.placeId
        self.countryName = model.address?.country?.name
        self.placeLong = placeLong
        self.placeLat = placeLat
        self.cityName = model.address?.district
        
        if let fullAddress = model.address?.label?.formatAddressField(),
           !fullAddress.isEmpty {
            self.name = fullAddress[safe: 0] ?? ""
            self.fullLocationAddress = fullAddress[safe: 1] ?? ""
        } else {
            self.name = model.title
            self.fullLocationAddress = model.address?.label
        }
        
        if let placeLat, let placeLong, let userLocation {
            let placeLocation = CLLocation(latitude: placeLat, longitude: placeLong)
            self.distance = placeLocation.distance(from: userLocation)
        } else {
            self.distance = nil
        }
        self.placeLabel = model.title
        self.placeType = model.placeType
        self.queryType = .none
        self.suggestType = .place
        self.queryId = nil
    }
    
    init(model: GeoPlacesClientTypes.SearchNearbyResultItem, placeLat: Double? = nil, placeLong: Double? = nil, userLocation: CLLocation? = nil) {
        self.placeId = model.placeId
        self.countryName = model.address?.country?.name
        self.placeLong = placeLong
        self.placeLat = placeLat
        self.cityName = model.address?.district
        
        if let fullAddress = model.address?.label?.formatAddressField(),
           !fullAddress.isEmpty {
            self.name = fullAddress[safe: 0] ?? ""
            self.fullLocationAddress = fullAddress[safe: 1] ?? ""
        } else {
            self.name = model.title
            self.fullLocationAddress = model.address?.label
        }
        
        if let placeLat, let placeLong, let userLocation {
            let placeLocation = CLLocation(latitude: placeLat, longitude: placeLong)
            self.distance = placeLocation.distance(from: userLocation)
        } else {
            self.distance = nil
        }
        self.placeLabel = model.title
        self.placeType = model.placeType
        self.queryType = .none
        self.suggestType = .none
        self.queryId = nil
    }
    
    init(model: GeoPlacesClientTypes.ReverseGeocodeResultItem, userLocation: CLLocation? = nil) {
        self.placeId = model.placeId
        self.countryName = model.address?.country?.name
        self.placeLong = model.position?.first
        self.placeLat = model.position?.last
        self.cityName = model.address?.district

        if let fullAddress = model.address?.label?.formatAddressField(),
           !fullAddress.isEmpty {
            self.name = fullAddress[safe: 0] ?? ""
            self.fullLocationAddress = fullAddress[safe: 1] ?? ""
        } else {
            self.name = model.title
            self.fullLocationAddress = model.address?.label
        }
        if let placeLat = self.placeLat, let placeLong = self.placeLong, let userLocation {
            let placeLocation = CLLocation(latitude: placeLat, longitude: placeLong)
            self.distance = placeLocation.distance(from: userLocation)
        } else {
            self.distance = nil
        }
        self.placeLabel = model.title
        self.placeType = model.placeType
        self.queryType = .none
        self.suggestType = .none
        self.queryId = nil
    }
    
    init(model: GetPlaceOutput) {
        self.placeId = model.placeId
        if let fullAddress = model.address?.label?.formatAddressField() {
            self.name = fullAddress[safe: 0] ?? ""
            self.fullLocationAddress = fullAddress[safe: 1] ?? ""
        } else {
            self.name = nil
            self.fullLocationAddress = nil
        }
        self.countryName = model.address?.country?.name
        if let point = model.position {
            self.placeLong = point[0]
            self.placeLat = point[1]
        } else {
            self.placeLong = nil
            self.placeLat = nil
        }
        self.distance = nil
        self.cityName = model.address?.district
        self.placeLabel = model.title
        self.placeType = model.placeType
        self.queryType = .none
        self.suggestType = .none
        self.queryId = nil
        self.place = model
    }
    
    init(model: GeoPlacesClientTypes.SuggestResultItem, userLocation: CLLocation? = nil) {
        self.placeId = model.place?.placeId
        if let fullAddress = model.place?.address?.label?.formatAddressField() {
            self.name = fullAddress[safe: 0] ?? model.place?.address?.label
            self.fullLocationAddress = fullAddress[safe: 1] ?? ""
        } else {
            self.name = model.title
            self.fullLocationAddress = nil
        }
        self.countryName = model.place?.address?.country?.name
        self.placeLong = model.place?.position?.first
        self.placeLat = model.place?.position?.last
        if let distance = model.place?.distance {
            self.distance = Double(distance)
        }
        else {
            self.distance = 0
        }
        self.cityName = model.place?.address?.district
        self.placeLabel = model.title
        self.placeType = model.place?.placeType
        self.queryType = model.query?.queryType
        self.suggestType = model.suggestResultItemType
        self.queryId = model.query?.queryId
    }
    
    init(model: GeoPlacesClientTypes.SearchTextResultItem, userLocation: CLLocation?) {
        self.placeId = model.placeId
        self.countryName = model.address?.country?.name
       
        if let fullAddress = model.address?.label?.formatAddressField() {
           self.name = fullAddress[safe: 0] ?? ""
           self.fullLocationAddress = fullAddress[safe: 1] ?? ""
       } else {
           self.name = nil
           self.fullLocationAddress = nil
       }
        self.placeLong = model.position?.first
        self.placeLat = model.position?.last
        self.distance = Double(model.distance)
       
        self.cityName = model.address?.district
        self.placeLabel = model.title
        self.placeType = model.placeType
        self.queryType = .none
        self.suggestType = .place
        self.queryId = nil
   }
}
