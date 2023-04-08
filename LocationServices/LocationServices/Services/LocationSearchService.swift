//
//  LocationSearchService.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocationXCF

enum LocationServiceConstant {
    static let maxResult: NSNumber = 5
}

protocol AWSLocationSearchService {
    func searchTextRequest(text: String, userLat: Double?, userLong: Double?, completion: @escaping([AWSLocationSearchForTextResult]?)->Void )
    func searchTextWithSuggesstionRequest(text: String, userLat: Double?, userLong: Double?, completion: @escaping([AWSLocationSearchForSuggestionsResult]?)->Void )
    func searchWithPositionRequest(text: [NSNumber], completion: @escaping ((Result<[AWSLocationSearchForPositionResult], Error>) -> Void))
    func getPlaceRequest(with placeId: String, completion: @escaping(AWSLocationGetPlaceResponse?)->Void )
}

extension AWSLocationSearchService {
    
  
    func searchTextRequest(text: String,
                           userLat: Double?,
                           userLong: Double?,
                           completion: @escaping([AWSLocationSearchForTextResult]?)->Void ) {
        
        let request = AWSLocationSearchPlaceIndexForTextRequest()!
        request.language = Locale.currentLanguageIdentifier()
        request.text = text
        request.indexName = getIndexName()
        if let lat = userLat, let long = userLong {
            let biasPosition = [NSNumber(value: long), NSNumber(value: lat)]
            request.biasPosition = biasPosition
        }
        
        let result = AWSLocation(forKey: "default").searchPlaceIndex(forText: request)
        result.continueWith { (task) -> Any? in
            if let error = task.error {
                print("error \(error)")
            } else if let taskResult = task.result,
                        let searchResult = taskResult.results {
                completion(searchResult)
            }
            return nil
        }
    }
    
    func searchTextWithSuggesstionRequest(text: String,
                                          userLat: Double?,
                                          userLong: Double?,
                                          completion: @escaping([AWSLocationSearchForSuggestionsResult]?)->Void ) {
        
        let request = AWSLocationSearchPlaceIndexForSuggestionsRequest()!
        request.language = Locale.currentLanguageIdentifier()
        request.text = text
        request.indexName = getIndexName()
        request.maxResults = LocationServiceConstant.maxResult
        if let lat = userLat, let long = userLong {
            let biasPosition = [NSNumber(value: long), NSNumber(value: lat)]
            request.biasPosition = biasPosition
        }
        
        let result = AWSLocation(forKey: "default").searchPlaceIndex(forSuggestions: request)
        result.continueWith { (task) -> Any? in
            if let error = task.error {
                print("error \(error)")
            } else if let taskResult = task.result,
                      let searchResult = taskResult.results {
                completion(searchResult)
            }
            return nil
        }
    }
    
    func getPlaceRequest(with placeId: String, completion: @escaping(AWSLocationGetPlaceResponse?)->Void ) {
        let request = AWSLocationGetPlaceRequest()!
        request.language = Locale.currentLanguageIdentifier()
        request.placeId = placeId
        request.indexName = getIndexName()
        
        let result = AWSLocation(forKey: "default").getPlace(request)
        
        result.continueWith { response in
            if let result = response.result {
                completion(result)
            } else {
                let error = response.error
                print("error \(String(describing: error))")
                completion(nil)
            }
            return nil
        }
    }
    
    func searchWithPositionRequest(text: [NSNumber], completion: @escaping ((Result<[AWSLocationSearchForPositionResult], Error>) -> Void)) {
        let request = AWSLocationSearchPlaceIndexForPositionRequest()!
        request.language = Locale.currentLanguageIdentifier()
        request.position = text
        request.indexName = getIndexName()
        
        let result = AWSLocation(forKey: "default").searchPlaceIndex(forPosition: request)
        
        result.continueWith { response in
            if let results = response.result?.results {
                completion(.success(results))
            } else {
                let defaultError = NSError(domain: "Location", code: -1)
                let error = response.error ?? defaultError
                print("error \(error)")
                completion(.failure(error))
            }
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
