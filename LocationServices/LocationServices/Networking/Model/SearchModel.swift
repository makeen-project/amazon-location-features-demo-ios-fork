//
//  SearchModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

struct SearchModel: Codable {
    let summary: Summary?
    let results: [Results]
    
    enum CodingKeys: String, CodingKey {
        case summary = "Summary"
        case results = "Results"
    }
}

struct Summary: Codable {
    let text: String
    let maxResults: Int
    
    enum CodingKeys: String, CodingKey {
        case text = "Text"
        case maxResults = "MaxResults"
    }
}

struct Results: Codable {
    let place: Place
    
    enum CodingKeys: String, CodingKey {
        case place = "Place"
    }
}

struct Place: Codable {
    let label: String
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case label = "Label"
        case country = "Country"
    }
}
