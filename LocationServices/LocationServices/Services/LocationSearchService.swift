//
//  LocationSearchService.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocation

enum LocationServiceConstant {
    static let maxResult: NSNumber = 5
}

protocol AWSLocationSearchService {
    func searchTextRequest(text: String, userLat: Double?, userLong: Double?) async throws -> SearchPlaceIndexForTextOutput?
    func searchTextWithSuggesstionRequest(text: String,
                                          userLat: Double?,
                                          userLong: Double?) async throws -> SearchPlaceIndexForSuggestionsOutput?
    func getPlaceRequest(with placeId: String) async throws -> GetPlaceOutput?
    func searchWithPositionRequest(position: [Double]) async throws -> SearchPlaceIndexForPositionOutput?
}

extension AWSLocationSearchService {
    
  
    func searchTextRequest(text: String,
                           userLat: Double?,
                           userLong: Double?) async throws -> SearchPlaceIndexForTextOutput? {
        var biasPosition: [Double]? = nil
        if let lat = userLat, let long = userLong {
            biasPosition = [long, lat]
        }
        let input = SearchPlaceIndexForTextInput(biasPosition: biasPosition, indexName: getIndexName(), language: Locale.currentLanguageIdentifier(), text: text)

        if let client = try await AmazonLocationClient.defaultCognito()?.locationClient {
            let result = try await client.searchPlaceIndexForText(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func searchTextWithSuggesstionRequest(text: String,
                                          userLat: Double?,
                                          userLong: Double?) async throws -> SearchPlaceIndexForSuggestionsOutput? {
        var biasPosition: [Double]? = nil
        if let lat = userLat, let long = userLong {
            biasPosition = [long, lat]
        }
     
        let input = SearchPlaceIndexForSuggestionsInput(biasPosition: biasPosition, indexName: getIndexName(), language: Locale.currentLanguageIdentifier(), maxResults: LocationServiceConstant.maxResult as? Int, text: text)
        if let client = try await AmazonLocationClient.defaultCognito()?.locationClient {
            let result = try await client.searchPlaceIndexForSuggestions(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func getPlaceRequest(with placeId: String) async throws -> GetPlaceOutput? {
        let input = GetPlaceInput(indexName: getIndexName(), language: Locale.currentLanguageIdentifier(), placeId: placeId)
        if let client = try await AmazonLocationClient.defaultCognito()?.locationClient {
            let result = try await client.getPlace(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func searchWithPositionRequest(position: [Double]) async throws -> SearchPlaceIndexForPositionOutput? {
        let input = SearchPlaceIndexForPositionInput(indexName: getIndexName(), language: Locale.currentLanguageIdentifier(), position: position)
        if let client = try await AmazonLocationClient.defaultCognito()?.locationClient {
            let result = try await client.searchPlaceIndexForPosition(input: input)
            return result
        } else {
            return nil
        }
    }
}

extension AWSLocationSearchService {
    private func getIndexName() -> String {
        let localData = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        switch localData?.type {
        case .esri, .none:
            return DataProviderName.esri.placeIndexesName
        case .here:
            return DataProviderName.here.placeIndexesName
        }        
    }
}
