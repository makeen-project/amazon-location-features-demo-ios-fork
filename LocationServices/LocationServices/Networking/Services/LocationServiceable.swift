//
//  LocationServiceable.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation
import AWSLocationXCF

protocol LocationServiceable {
    func searchText(text: String, userLat: Double?, userLong: Double?, completion: @escaping (([SearchPresentation]) -> Void))
    func searchTextWithSuggestion(text: String, userLat: Double?, userLong: Double?, completion: @escaping (([SearchPresentation]) -> Void))
    func searchWithPosition(text: [NSNumber], userLat: Double?, userLong: Double?, completion: @escaping ((Result<[SearchPresentation], Error>) -> Void)) -> AWSLocationSearchPlaceIndexForPositionRequest
    func getPlace(with placeId: String, completion: @escaping(SearchPresentation?)->Void )
    
}

struct LocationService: AWSLocationSearchService, LocationServiceable {
    
    func searchTextWithSuggestion(text: String, userLat: Double?, userLong: Double?, completion: @escaping (([SearchPresentation]) -> Void)) {
       searchTextWithSuggesstionRequest(text: text, userLat: userLat, userLong: userLong) { result in
           let result = result ?? []
           Task {
               let model = await result.asyncMap({ model in
                   guard let placeId = model.placeId else { return SearchPresentation(model: model) }
                   
                   var userLocation: CLLocation? = nil
                   if let userLat, let userLong {
                       userLocation = CLLocation(latitude: userLat, longitude: userLong)
                   }
                   
                   let place = await getPlace(with: placeId)
                   return SearchPresentation(model: model, placeLat: place?.placeLat, placeLong: place?.placeLong, userLocation: userLocation)
               })
               completion(model)
           }
       }
    }
    
    func searchText(text: String, userLat: Double?, userLong: Double?, completion: @escaping (([SearchPresentation]) -> Void)) {
        searchTextRequest(text: text, userLat: userLat, userLong: userLong) { result in
            if let result = result {
                let model = result.map(SearchPresentation.init)
                completion(model)
            }
        }
    }
    
    @discardableResult
    func searchWithPosition(text: [NSNumber], userLat: Double?, userLong: Double?, completion: @escaping ((Result<[SearchPresentation], Error>) -> Void)) -> AWSLocationSearchPlaceIndexForPositionRequest {
        return searchWithPositionRequest(text: text) { response in
            switch response {
            case .success(let resluts):
                var userLocation: CLLocation? = nil
                if let userLat, let userLong {
                    userLocation = CLLocation(latitude: userLat, longitude: userLong)
                }
                
                let model = resluts.map({ SearchPresentation(model: $0, userLocation: userLocation) })
                completion(.success(model))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getPlace(with placeId: String, completion: @escaping (SearchPresentation?) -> Void) {
        getPlaceRequest(with: placeId) { response in
            if let response = response {
                let model = SearchPresentation(model: response)
                completion(model)
            } else {
                completion(nil)
            }
        }
    }
    
    func getPlace(with placeId: String) async -> SearchPresentation? {
        return await withCheckedContinuation({ continuation in
            getPlace(with: placeId) { presentation in
                continuation.resume(returning: presentation)
            }
        })
    }
}
