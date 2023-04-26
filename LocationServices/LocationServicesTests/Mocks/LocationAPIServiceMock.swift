//
//  LocationAPIServiceMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
@testable import LocationServices
import AWSLocationXCF

class LocationAPIServiceMock: LocationServiceable {
    
    let delay: TimeInterval
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    var putSearchWithPositionResult: Result<[LocationServices.SearchPresentation], Error>?
    
    var putSearchTextResult: [LocationServices.SearchPresentation]?
    
    func searchText(text: String, userLat: Double?, userLong: Double?, completion: @escaping (([SearchPresentation]) -> Void)) {
        perform { [weak self] in
             guard let result = self?.putSearchTextResult else { return }
             completion(result)
         }
    }
    
    func searchTextWithSuggestion(text: String, userLat: Double?, userLong: Double?, completion: @escaping (([SearchPresentation]) -> Void)) {
        perform { [weak self] in
             guard let result = self?.putSearchTextResult else { return }
             completion(result)
         }
    }
    
    func searchWithPosition(text: [NSNumber], userLat: Double?, userLong: Double?, completion: @escaping ((Result<[SearchPresentation], Error>) -> Void)) {
        perform { [weak self] in
             guard let result = self?.putSearchWithPositionResult else { return }
             completion(result)
         }
    }
    
    @discardableResult
    func searchWithPosition(text: [NSNumber], userLat: Double?, userLong: Double?, completion: @escaping ((Result<[LocationServices.SearchPresentation], Error>) -> Void)) -> AWSLocationSearchPlaceIndexForPositionRequest {
       perform { [weak self] in
            guard let result = self?.putSearchWithPositionResult else { return }
            completion(result)
        }
        return AWSLocationSearchPlaceIndexForPositionRequest()
    }
    
    func getPlace(with placeId: String, completion: @escaping (SearchPresentation?) -> Void) {}
    
    private func perform(action: @escaping ()->()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            action()
        }
    }
}
