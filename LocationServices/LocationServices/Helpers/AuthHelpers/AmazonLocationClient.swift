//
//  AmazonLocationClient.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocation
import AWSGeoPlaces
import AWSGeoRoutes

public class AmazonLocationClient {
    public init() {
    }

    static func getCognitoLocationClient() async throws -> LocationClient? {
        return CognitoAuthHelper.default().locationClient
    }
    
    static func getApiLocationClient() -> LocationClient? {
        return ApiAuthHelper.default().locationClient
    }
    
    static func getPlacesClient() -> GeoPlacesClient? {
        return ApiAuthHelper.default().geoPlacesClient
    }
    
    static func getRoutesClient() -> GeoRoutesClient? {
        return ApiAuthHelper.default().geoRoutesClient
    }
    
    static func getApiKey() -> String? {
        return ApiAuthHelper.default().apiKey
    }
    
    static func getApiKeyRegion() -> String? {
        return ApiAuthHelper.default().region
    }
}
