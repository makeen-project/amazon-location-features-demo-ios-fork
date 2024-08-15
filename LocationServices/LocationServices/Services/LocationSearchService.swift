//
//  LocationSearchService.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocation
import AmazonLocationiOSAuthSDK

enum LocationServiceConstant {
    static let maxResult: NSNumber = 5
}

protocol AWSLocationSearchService {
    func searchTextRequest(text: String, userLat: Double?, userLong: Double?) async throws -> SearchPlaceIndexForTextOutput?
    func searchTextWithSuggesstionRequest(text: String,
                                          userLat: Double?,
                                          userLong: Double?) async throws -> SearchPlaceIndexForSuggestionsOutput?
    func getPlaceRequest(with placeId: String) async throws -> GetPlaceOutput?
    func searchWithPositionRequest(position: [Double]) async throws -> SearchPlaceIndexForPositionOutput?
}

public struct SearchTextEndpoint: AmazonLocationEndpoint {
    public func url() -> String {
        return BaseAPIEndpoint.baseUrl(apiKey: "", region: "", apiName: "places")
    }
    
    public func isApiKeyEndpoint() -> Bool {
        return true
    }
}

public struct SearchByTextRequest: Codable, EncodableRequest {
    public let language: String
    public let maxResults: Int
    public let biasPosition: [Double]?
    public let query: String
    
    enum CodingKeys: String, CodingKey {
        case language = "Language"
        case maxResults = "MaxResults"
        case biasPosition = "Position"
        case query = "Query"
    }
    
    public init(query: String, language: String, maxResults: Int, biasPosition: [Double]?) {
        self.query = query
        self.language = language
        self.maxResults = maxResults
        self.biasPosition = biasPosition
    }

    public func toData() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}

public struct Country: Codable {
    public let Code2: String
    public let Code3: String
    public let Name: String
}

public struct Region: Codable {
    public let Code: String
    public let Name: String
}

public struct Address: Codable {
    public let Label: String?
    public let Country: Country?
    public let Region: Region?
    public let Position: [Double]
    public let Distance: Double
    public let MapView: [Double]
}

public struct SearchResult: Codable {
    public let PlaceId: String
    public let Distance: Double
    public let Address: Address

}

public struct SearchByTextResponse: Decodable {
    public let ResultItems: [SearchResult]
    public let PricingTier: String
    public static func from(data: Data) throws -> SearchByTextResponse? {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(SearchByTextResponse.self, from: data)
            return response
        }
        catch {
            print(error)
            return nil
        }
    }
}

extension AWSLocationSearchService {
    
  
//    func searchTextRequest(text: String,
//                           userLat: Double?,
//                           userLong: Double?) async throws -> SearchPlaceIndexForTextOutput? {
//        var biasPosition: [Double]? = nil
//        if let lat = userLat, let long = userLong {
//            biasPosition = [long, lat]
//        }
//        let input = SearchPlaceIndexForTextInput(biasPosition: biasPosition, indexName: getIndexName(), language: Locale.currentLanguageIdentifier(), text: text)
//
//        if let client = AmazonLocationClient.defaultCognito()?.locationClient {
//            let result = try await client.searchPlaceIndexForText(input: input)
//            return result
//        } else {
//            return nil
//        }
//    }
    
    func searchTextRequest(text: String,
                           userLat: Double?,
                           userLong: Double?) async throws -> SearchPlaceIndexForTextOutput? {
        var biasPosition: [Double]? = nil
        if let lat = userLat, let long = userLong {
            biasPosition = [long, lat]
        }
        
        let endpoint = SearchTextEndpoint()
        let request = SearchByTextRequest(query: text, language: "en", maxResults: 20, biasPosition: biasPosition)
        let response: AmazonLocationResponse<SearchByTextResponse, AmazonErrorResponse>? = try await AmazonLocationClient.defaultApi()?.sendAPIRequest(serviceName: AmazonService.Location, endpoint: endpoint, httpMethod: .GET, requestBody: request, successType: SearchByTextResponse.self, errorType: AmazonErrorResponse.self)
        let input = SearchPlaceIndexForTextInput(biasPosition: biasPosition, indexName: getIndexName(), language: Locale.currentLanguageIdentifier(), text: text)

        if let client = AmazonLocationClient.defaultCognito()?.locationClient {
            let result = try await client.searchPlaceIndexForText(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func searchTextWithSuggesstionRequest(text: String,
                                          userLat: Double?,
                                          userLong: Double?) async throws -> SearchPlaceIndexForSuggestionsOutput? {
        var biasPosition: [Double]? = nil
        if let lat = userLat, let long = userLong {
            biasPosition = [long, lat]
        }
        let input = SearchPlaceIndexForSuggestionsInput(biasPosition: biasPosition, indexName: getIndexName(), language: Locale.currentLanguageIdentifier(), maxResults: LocationServiceConstant.maxResult as? Int, text: text)
        let client1 = AmazonLocationClient.defaultCognito()?.locationClient
        if let client = AmazonLocationClient.defaultCognito()?.locationClient {
            let result = try await client.searchPlaceIndexForSuggestions(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func getPlaceRequest(with placeId: String) async throws -> GetPlaceOutput? {
        let input = GetPlaceInput(indexName: getIndexName(), language: Locale.currentLanguageIdentifier(), placeId: placeId)
        if let client = AmazonLocationClient.defaultCognito()?.locationClient {
            let result = try await client.getPlace(input: input)
            return result
        } else {
            return nil
        }
    }
    
    func searchWithPositionRequest(position: [Double]) async throws -> SearchPlaceIndexForPositionOutput? {
        let input = SearchPlaceIndexForPositionInput(indexName: getIndexName(), language: Locale.currentLanguageIdentifier(), position: position)
        if let client = AmazonLocationClient.defaultCognito()?.locationClient {
            let result = try await client.searchPlaceIndexForPosition(input: input)
            return result
        } else {
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
