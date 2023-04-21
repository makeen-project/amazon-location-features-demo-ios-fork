//
//  LocationAPIServiceMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
@testable import LocationServices

class LocationAPIServiceMock: LocationServiceable {
    func searchText(text: String, userLat: Double?, userLong: Double?, completion: @escaping (([SearchPresentation]) -> Void)) {}
    func searchTextWithSuggestion(text: String, userLat: Double?, userLong: Double?, completion: @escaping (([SearchPresentation]) -> Void)) {}
    func searchWithPosition(text: [NSNumber], userLat: Double?, userLong: Double?, completion: @escaping ((Result<[SearchPresentation], Error>) -> Void)) {}
    func getPlace(with placeId: String, completion: @escaping (SearchPresentation?) -> Void) {}
}
