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
    func searchWithSuggestRequest(text: String,
                                          userLat: Double?,
                                          userLong: Double?) async throws -> SuggestOutput?
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
        let input = SearchTextInput(biasPosition: biasPosition, key: AmazonLocationClient.defaultApiKey(), language: Locale.currentLanguageIdentifier(), queryText: text)

        if let client = AmazonLocationClient.defaultApiPlacesClient() {
            let result = try await client.searchText(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func searchWithSuggestRequest(text: String,
                                          userLat: Double?,
                                           userLong: Double?) async throws -> SuggestOutput? {
        var biasPosition: [Double]? = nil
        if let lat = userLat, let long = userLong {
            biasPosition = [long, lat]
        }
     
        let input = SuggestInput(biasPosition: biasPosition, key: AmazonLocationClient.defaultApiKey(), language: Locale.currentLanguageIdentifier(), queryText: text)
        if let client = AmazonLocationClient.defaultApiPlacesClient() {
            let result = try await client.suggest(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func getPlaceRequest(with placeId: String) async throws -> GetPlaceOutput? {
        let input = GetPlaceInput(key: AmazonLocationClient.defaultApiKey(), language: Locale.currentLanguageIdentifier(), placeId: placeId)
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
