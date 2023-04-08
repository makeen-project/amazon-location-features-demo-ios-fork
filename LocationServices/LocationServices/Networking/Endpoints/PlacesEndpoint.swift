//
//  PlacesEndpoint.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

enum PlacesEndpoint {
    case geocoding(searchText: String)
}

extension PlacesEndpoint: Endpoint {
    var httpMethod: HttpMethod {
        return .post
    }

    var path: String {
        switch self {
        case .geocoding(let searchText):
            return "/places/v0/indexes/Esri/search/\(searchText)"
        }
    }
    
    var method: HttpMethod {
        switch self {
        case .geocoding:
            return .post
        }
    }
    
    var header: [String: String]? {
        switch self {
        case .geocoding:
            return [
                "Content-Type": "application/json"
            ]
        }
    }
    
    var body: [String: String]? {
        switch self {
        case.geocoding:
            return [
                "IndexName": "explore.place",
                 "Text": "New york, NY",
            ]
        }
    }
}
