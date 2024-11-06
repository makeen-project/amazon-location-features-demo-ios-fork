//
//  ApiAuthHelper.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSGeoRoutes
import AWSGeoPlaces
import AWSLocation
import AmazonLocationiOSAuthSDK

public class ApiAuthHelper {

    private static var _sharedInstance: ApiAuthHelper?
    var locationClient: LocationClient?
    var geoPlacesClient: GeoPlacesClient?
    var geoRoutesClient: GeoRoutesClient?
    var authHelper: AuthHelper?
    var apiKey: String?
    var region: String?
    
    static func initialise(apiKey: String, region: String) async throws {
        if _sharedInstance == nil {
            _sharedInstance = ApiAuthHelper()
            _sharedInstance?.apiKey = apiKey
            _sharedInstance?.region = region
            let authHelper = try await AuthHelper.withApiKey(apiKey: apiKey, region: region)
            _sharedInstance?.authHelper = authHelper
            let locationClientConfig = authHelper.getLocationClientConfig()
            _sharedInstance?.locationClient = LocationClient(config: locationClientConfig)
            let placesClientConfig = authHelper.getGeoPlacesClientConfig()
            _sharedInstance?.geoPlacesClient = GeoPlacesClient(config: placesClientConfig)
            let routesClientConfig = authHelper.getGeoRoutesClientConfig()
            _sharedInstance?.geoRoutesClient = GeoRoutesClient(config: routesClientConfig)
        }
    }
    
    static func `default`() -> ApiAuthHelper {
        return _sharedInstance!
    }
}
