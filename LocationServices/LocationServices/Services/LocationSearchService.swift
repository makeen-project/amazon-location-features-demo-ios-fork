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
    func searchTextRequest(text: String, userLat: Double?, userLong: Double?, queryId: String?) async throws -> SearchTextOutput?
    func searchWithSuggestRequest(text: String,
                                          userLat: Double?,
                                          userLong: Double?) async throws -> SuggestOutput?
    func getPlaceRequest(with placeId: String) async throws -> GetPlaceOutput?
    func reverseGeocodeRequest(position: [Double]) async throws -> ReverseGeocodeOutput?
}

extension AWSLocationSearchService {
    
  
    func searchTextRequest(text: String,
                           userLat: Double?,
                           userLong: Double?, queryId: String? = nil) async throws -> SearchTextOutput? {
        var biasPosition: [Double]? = nil
        if let lat = userLat, let long = userLong {
            biasPosition = [long, lat]
        }
        else {
            biasPosition = [AppConstants.amazonHqMapPosition.longitude, AppConstants.amazonHqMapPosition.latitude]
        }
        let politicalView = UserDefaultsHelper.getObject(value: PoliticalViewType.self, key: .politicalView)
        let input = SearchTextInput(biasPosition: queryId == nil ? biasPosition: nil, language: queryId == nil ? Locale.currentAppLanguageIdentifier() : nil, politicalView: queryId == nil ? politicalView?.countryCode : nil, queryId: queryId, queryText: queryId == nil ? text : nil)

        if let client = AmazonLocationClient.getPlacesClient() {
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
        else {
            biasPosition = [AppConstants.amazonHqMapPosition.longitude, AppConstants.amazonHqMapPosition.latitude]
        }
        let politicalView = UserDefaultsHelper.getObject(value: PoliticalViewType.self, key: .politicalView)
        let input = SuggestInput(additionalFeatures: [.sdkUnknown("Core")], biasPosition: biasPosition, language: Locale.currentAppLanguageIdentifier(), politicalView: politicalView?.countryCode, queryText: text)
        if let client = AmazonLocationClient.getPlacesClient() {
            let result = try await client.suggest(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func getPlaceRequest(with placeId: String) async throws -> GetPlaceOutput? {
        let politicalView = UserDefaultsHelper.getObject(value: PoliticalViewType.self, key: .politicalView)
        let input = GetPlaceInput(additionalFeatures: [GeoPlacesClientTypes.GetPlaceAdditionalFeature.contact], language: Locale.currentAppLanguageIdentifier(), placeId: placeId, politicalView: politicalView?.countryCode)
        if let client = AmazonLocationClient.getPlacesClient() {
            let result = try await client.getPlace(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func reverseGeocodeRequest(position: [Double]) async throws -> ReverseGeocodeOutput? {
        let politicalView = UserDefaultsHelper.getObject(value: PoliticalViewType.self, key: .politicalView)
        let input = ReverseGeocodeInput(language: Locale.currentAppLanguageIdentifier(), politicalView: politicalView?.countryCode, queryPosition: position, queryRadius: 50)
        if let client = AmazonLocationClient.getPlacesClient() {
            let result = try await client.reverseGeocode(input: input)
            return result
        } else {
            return nil
        }
    }
}
