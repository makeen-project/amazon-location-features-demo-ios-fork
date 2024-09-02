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
    func searchTextWithSuggestion(text: String, userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error>
    func searchWithPosition(position: [Double], userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error>
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
            let model = result!.results!.map({ SearchPresentation(model: $0, userLocation: userLocation) })
            return .success(model)
        }
        catch {
            return .failure(error)
        }
    }
    
    func searchTextWithSuggestion1(text: String, userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error>  {
        do {
            let result = try await searchTextWithSuggesstionRequest(text: text, userLat: userLat, userLong: userLong)
            let model = try await result!.results!.asyncMap({ model in
                guard let placeId = model.placeId else { return SearchPresentation(model: model) }
                
                var userLocation: CLLocation? = nil
                if let userLat, let userLong {
                    userLocation = CLLocation(latitude: userLat, longitude: userLong)
                }
                
                let place = try await getPlace(with: placeId)
                return SearchPresentation(model: model, placeLat: place?.placeLat, placeLong: place?.placeLong, userLocation: userLocation)
            })
            return .success(model)
        }
        catch {
            return .failure(error)
        }
    }
    
    func searchTextWithSuggestion(text: String, userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error>  {
        do {
            let result = try await searchTextWithSuggesstionRequest(text: text, userLat: userLat, userLong: userLong)
            let model = try await result!.results!.asyncMap({ model in
                guard let placeId = model.placeId else { return SearchPresentation(model: model) }
                
                var userLocation: CLLocation? = nil
                if let userLat, let userLong {
                    userLocation = CLLocation(latitude: userLat, longitude: userLong)
                }
                
                let place = try await getPlace(with: placeId)
                return SearchPresentation(model: model, placeLat: place?.placeLat, placeLong: place?.placeLong, userLocation: userLocation)
            })
            return .success(model)
        }
        catch {
            return .failure(error)
        }
    }
    
    //@discardableResult
    func searchWithPosition(position: [Double], userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error> {
        do {
            let result = try await searchWithPositionRequest(position: position)
            
            var userLocation: CLLocation? = nil
            if let userLat, let userLong {
                userLocation = CLLocation(latitude: userLat, longitude: userLong)
            }
            
            let model = result!.results!.map({ SearchPresentation(model: $0, userLocation: userLocation) })
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
    
//    func getPlace(with placeId: String) async throws -> SearchPresentation? {
//        return await withCheckedContinuation({ continuation in
//            getPlace(with: placeId) { presentation in
//                continuation.resume(returning: presentation)
//            }
//        })
//    }
}
