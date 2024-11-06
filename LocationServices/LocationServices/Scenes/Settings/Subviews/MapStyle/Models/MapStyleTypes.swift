//
//  MapStyleTypes.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

enum MapStyleImages: Codable  {
    case standard, monochrome, hybrid, satellite
    
    var mapName: String {
        switch self {
        case .standard:
            return "Standard"
        case .monochrome:
            return "Monochrome"
        case .hybrid:
            return "Hybrid"
        case .satellite:
            return "Satellite"
        }
    }
}

enum MapStyleColorType: String, Codable {
    case light, dark
    
    var colorName: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}

struct PoliticalViewType: Codable {
    let countryCode: String
    let flagCode: String
    let fullName: String
    let politicalDescription: String
}


let PoliticalViewTypes: [PoliticalViewType] = [
    PoliticalViewType(countryCode: "ARG", flagCode: "AR", fullName: "Argentina", politicalDescription: "Argentina's view on the Southern Patagonian Ice Field and Tierra Del Fuego, including the Falkland Islands, South Georgia, and South Sandwich Islands"),
    PoliticalViewType(countryCode: "EGY", flagCode: "EG", fullName: "Egypt", politicalDescription: "Egypt's view on Bir Tawil"),
    PoliticalViewType(countryCode: "IND", flagCode: "IN", fullName: "India", politicalDescription: "India's view on Gilgit-Baltistan"),
    PoliticalViewType(countryCode: "KEN", flagCode: "KE", fullName: "Kenya", politicalDescription: "Kenya's view on the Ilemi Triangle"),
    PoliticalViewType(countryCode: "MAR", flagCode: "MA", fullName: "Morocco", politicalDescription: "Morocco's view on Western Sahara"),
    PoliticalViewType(countryCode: "RUS", flagCode: "RU", fullName: "Russia", politicalDescription: "Russia's view on Crimea"),
    PoliticalViewType(countryCode: "SDN", flagCode: "SD", fullName: "Sudan", politicalDescription: "Sudan's view on the Halaib Triangle"),
    PoliticalViewType(countryCode: "SRB", flagCode: "RS", fullName: "Serbia", politicalDescription: "Serbia's view on Kosovo, Vukovar, and Sarengrad Islands"),
    PoliticalViewType(countryCode: "SUR", flagCode: "SR", fullName: "Suriname", politicalDescription: "Suriname's view on the Courantyne Headwaters and Lawa Headwaters"),
    PoliticalViewType(countryCode: "SYR", flagCode: "SY", fullName: "Syria", politicalDescription: "Syria's view on the Golan Heights"),
    PoliticalViewType(countryCode: "TUR", flagCode: "TR", fullName: "Turkey", politicalDescription: "Turkey's view on Cyprus and Northern Cyprus"),
    PoliticalViewType(countryCode: "TZA", flagCode: "TZ", fullName: "Tanzania", politicalDescription: "Tanzania's view on Lake Malawi"),
    PoliticalViewType(countryCode: "URY", flagCode: "UY", fullName: "Uruguay", politicalDescription: "Uruguay's view on Rincon de Artigas"),
    PoliticalViewType(countryCode: "VNM", flagCode: "VN", fullName: "Vietnam", politicalDescription: "Vietnam's view on the Paracel Islands and Spratly Islands")
]
