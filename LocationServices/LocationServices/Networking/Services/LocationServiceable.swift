//
//  LocationServiceable.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSLocation

protocol LocationServiceable {
    func searchText(text: String, userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error>
    func searchWithSuggest(text: String, userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error>
    func reverseGeocode(position: [Double], userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error>
    func getPlace(with placeId: String) async throws -> SearchPresentation?
    
}

struct LocationService: AWSLocationSearchService, LocationServiceable {
    
    func searchText(text: String, userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error> {
        do {
            let result = try await searchTextRequest(text: text, userLat: userLat, userLong: userLong)
            var userLocation: CLLocation? = nil
            if let userLat, let userLong {
                userLocation = CLLocation(latitude: userLat, longitude: userLong)
            }
            let model = result!.resultItems!.map({ SearchPresentation(model: $0, userLocation: userLocation) })
            return .success(model)
        }
        catch {
            return .failure(error)
        }
    }
    
    func searchWithSuggest(text: String, userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error>  {
        do {
            let result = try await searchWithSuggestRequest(text: text, userLat: userLat, userLong: userLong)
            let model = result!.resultItems!.map({ model in
                return SearchPresentation(model: model)
            })
            return .success(model)
        }
        catch {
            print(error)
            return .failure(error)
        }
    }
    
    //@discardableResult
    func reverseGeocode(position: [Double], userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error> {
        do {
            let result = try await reverseGeocodeRequest(position: position)
            var userLocation: CLLocation? = nil
            if let userLat, let userLong {
                userLocation = CLLocation(latitude: userLat, longitude: userLong)
            }
            let model = result!.resultItems!.map({ SearchPresentation(model: $0, userLocation: userLocation) })
            return .success(model)
        }
        catch {
            return .failure(error)
        }
    }
    
    func getPlace(with placeId: String) async throws -> SearchPresentation? {
        let response = try await getPlaceRequest(with: placeId)
        let model = SearchPresentation(model: response!)
        return model
    }
}
