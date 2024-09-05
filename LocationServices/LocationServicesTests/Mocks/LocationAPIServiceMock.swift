//
//  LocationAPIServiceMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
@testable import LocationServices
import AWSLocation

class LocationAPIServiceMock: LocationServiceable {
    var mockSearchTextResult: Result<[SearchPresentation], Error> = .success([])
    var mockSearchTextWithSuggestionResult: Result<[SearchPresentation], Error> = .success([])
    var mockSearchWithPositionResult: Result<[SearchPresentation], Error> = .success([])
    var mockGetPlaceResult: Result<SearchPresentation?, Error> = .success(nil)
    
    let delay: TimeInterval
        
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func searchText(text: String, userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error> {
        return mockSearchTextResult
    }
    
    func searchTextWithSuggestion(text: String, userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error> {
        return mockSearchTextWithSuggestionResult
    }
    
    func searchWithPosition(position: [Double], userLat: Double?, userLong: Double?) async -> Result<[SearchPresentation], Error> {
        return mockSearchWithPositionResult
    }
    
    func getPlace(with placeId: String) async throws -> SearchPresentation? {
        switch mockGetPlaceResult {
        case .success(let model):
            return model
        case .failure(let error):
            throw error
        }
    }
}

