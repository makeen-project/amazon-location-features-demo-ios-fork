//
//  SearchPresentation.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocationXCF
import CoreLocation


struct SearchPresentation {
    let placeId: String?
    let fullLocationAddress: String?
    let distance: Int?
    let countryName: String?
    let cityName: String?
    let placeLat: Double?
    let placeLong: Double?
    let name: String?
    
    init( placeId: String?,
          fullLocationAddress: String?,
          distance: Int?,
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
    }
    
    init(model: AWSLocationSearchForTextResult) {
        self.placeId = model.placeId
        self.countryName = model.place?.country
        if let fullAddress = model.place?.label?.formatAddressField() {
            self.name = fullAddress[safe: 0] ?? ""
            self.fullLocationAddress = fullAddress[safe: 1] ?? ""
        } else {
            self.name = nil
            self.fullLocationAddress = nil
        }
        self.distance = model.distance?.intValue
        if let point = model.place?.geometry?.point {
            self.placeLong = point[0].doubleValue
            self.placeLat = point[1].doubleValue
        } else {
            self.placeLong = nil
            self.placeLat = nil
        }
        self.cityName = model.place?.municipality
    }
    
    init(model: AWSLocationSearchForSuggestionsResult, placeLat: Double? = nil, placeLong: Double? = nil, userLocation: CLLocation? = nil) {
        self.placeId = model.placeId
        self.countryName = nil
        self.placeLong = placeLong
        self.placeLat = placeLat
        self.cityName = nil
        
        if let fullAddress = model.text?.formatAddressField(),
           !fullAddress.isEmpty {
            self.name = fullAddress[safe: 0] ?? ""
            self.fullLocationAddress = fullAddress[safe: 1] ?? ""
        } else {
            self.name = model.text
            self.fullLocationAddress = model.text
        }
        
        if let placeLat, let placeLong, let userLocation {
            let placeLocation = CLLocation(latitude: placeLat, longitude: placeLong)
            self.distance = Int(placeLocation.distance(from: userLocation))
        } else {
            self.distance = nil
        }
    }
    
    init(model: AWSLocationGetPlaceResponse) {
        self.placeId = nil
        if let fullAddress = model.place?.label?.formatAddressField() {
            self.name = fullAddress[safe: 0] ?? ""
            self.fullLocationAddress = fullAddress[safe: 1] ?? ""
        } else {
            self.name = nil
            self.fullLocationAddress = nil
        }
        self.countryName = model.place?.country
        if let point = model.place?.geometry?.point {
            self.placeLong = point[0].doubleValue
            self.placeLat = point[1].doubleValue
        } else {
            self.placeLong = nil
            self.placeLat = nil
        }
        self.distance = nil
        self.cityName = model.place?.municipality
    }
    
    init(model: AWSLocationSearchForPositionResult, userLocation: CLLocation?) {
     
        self.placeId = model.placeId
        self.countryName = model.place?.country
        
        if let fullAddress = model.place?.label?.formatAddressField() {
            self.name = fullAddress[safe: 0] ?? ""
            self.fullLocationAddress = fullAddress[safe: 1] ?? ""
        } else {
            self.name = nil
            self.fullLocationAddress = nil
        }
        
        if let point = model.place?.geometry?.point {
            //class LocationService -> func searchWithPosition -> func searchWithPositionRequest -> AWSLocationSearchPlaceIndexForPositionRequest
            // AWSLocationSearchPlaceIndexForPositionRequest - geometry contains [longitude, latitude]
            self.placeLong = point[0].doubleValue
            self.placeLat = point[1].doubleValue
        } else {
            self.placeLong = nil
            self.placeLat = nil
        }
        
        //there is no ability to send user location in request,
        //so destination is incorrect in response
        //and needed to be recalculated
        if let placeLat, let placeLong, let userLocation {
            let placeLocation = CLLocation(latitude: placeLat, longitude: placeLong)
            self.distance = Int(placeLocation.distance(from: userLocation))
        } else {
            self.distance = model.distance?.intValue
        }
        
        self.cityName = model.place?.municipality
    }
}
