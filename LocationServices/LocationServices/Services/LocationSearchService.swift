//
//  LocationSearchService.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSGeoPlaces

enum LocationServiceConstant {
    static let maxResult: NSNumber = 5
}

protocol AWSLocationSearchService {
    func searchTextRequest(text: String, userLat: Double?, userLong: Double?) async throws -> SearchTextOutput?
    func searchTextWithAutocompleteRequest(text: String,
                                          userLat: Double?,
                                          userLong: Double?) async throws -> AutocompleteOutput?
    func getPlaceRequest(with placeId: String) async throws -> GetPlaceOutput?
    func searchNearbyRequest(position: [Double]) async throws -> SearchNearbyOutput?
}

extension AWSLocationSearchService {
    
  
    func searchTextRequest(text: String,
                           userLat: Double?,
                           userLong: Double?) async throws -> SearchTextOutput? {
        var biasPosition: [Double]? = nil
        if let lat = userLat, let long = userLong {
            biasPosition = [long, lat]
        }
        let input = SearchTextInput(biasPosition: biasPosition, language: Locale.currentLanguageIdentifier(), queryText: text)

        if let client = AmazonLocationClient.defaultApiPlacesClient() {
            let result = try await client.searchText(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func searchTextWithAutocompleteRequest(text: String,
                                          userLat: Double?,
                                           userLong: Double?) async throws -> AutocompleteOutput? {
        var biasPosition: [Double]? = nil
        if let lat = userLat, let long = userLong {
            biasPosition = [long, lat]
        }
     
        let input = AutocompleteInput(biasPosition: biasPosition, intendedUse: .storage, key: AmazonLocationClient.defaultApiKey(), language: Locale.currentLanguageIdentifier(), queryText: text)
        if let client = AmazonLocationClient.defaultApiPlacesClient() {
            let result = try await client.autocomplete(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func getPlaceRequest(with placeId: String) async throws -> GetPlaceOutput? {
        let input = GetPlaceInput(language: Locale.currentLanguageIdentifier(), placeId: placeId)
        if let client = AmazonLocationClient.defaultApiPlacesClient() {
            let result = try await client.getPlace(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func searchNearbyRequest(position: [Double]) async throws -> SearchNearbyOutput? {
        let input = SearchNearbyInput(key: AmazonLocationClient.defaultApiKey(), language: Locale.currentLanguageIdentifier(), queryPosition: position, queryRadius: 50)
        if let client = AmazonLocationClient.defaultApiPlacesClient() {
            let result = try await client.searchNearby(input: input)
            return result
        } else {
            return nil
        }
    }
}
