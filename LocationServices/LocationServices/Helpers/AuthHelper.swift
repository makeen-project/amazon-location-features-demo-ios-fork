//
//  AuthHelper.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AwsCommonRuntimeKit
import AWSGeoPlaces
import SmithyHTTPAuthAPI

public class AuthHelper {

    private var locationCredentialsProvider: LocationCredentialsProvider?
    private var amazonLocationClient: AmazonLocationClient?
    private var geoPlacesClient: GeoPlacesClient?
    
    public init() {
    }
    
    public func authenticateWithCognitoIdentityPool(identityPoolId: String) async throws -> LocationCredentialsProvider? {
        let region = identityPoolId.toRegionString()
        locationCredentialsProvider = try? await authenticateWithCognitoIdentityPoolAndRegion(identityPoolId: identityPoolId, region: region)
        return locationCredentialsProvider
    }
    
    public func authenticateWithCognitoIdentityPool(identityPoolId: String, region: String) async throws -> LocationCredentialsProvider? {
        locationCredentialsProvider = try? await authenticateWithCognitoIdentityPoolAndRegion(identityPoolId: identityPoolId, region: region)
        return locationCredentialsProvider
    }
    
    private func authenticateWithCognitoIdentityPoolAndRegion(identityPoolId: String, region: String) async throws -> LocationCredentialsProvider? {
        let credentialProvider = LocationCredentialsProvider(region: region, identityPoolId: identityPoolId)
        credentialProvider.setRegion(region: region)
        try await credentialProvider.getCognitoProvider()?.refreshCognitoCredentialsIfExpired()
        amazonLocationClient = AmazonLocationClient(locationCredentialsProvider: credentialProvider)
        return credentialProvider
    }

    public func authenticateWithApiKey(apiKey: String, region: String) throws -> LocationCredentialsProvider {
        let credentialProvider = LocationCredentialsProvider(region: region, apiKey: apiKey)
        credentialProvider.setAPIKey(apiKey: apiKey)
        credentialProvider.setRegion(region: region)
        locationCredentialsProvider = credentialProvider
        amazonLocationClient = AmazonLocationClient(locationCredentialsProvider: credentialProvider)
        
        let resolver: AuthSchemeResolver = ApiKeyAuthSchemeResolver()
        let signer = ApiKeySigner()
        let authScheme: AuthScheme = ApiKeyAuthScheme(signer: signer)
        let authSchemes: [AuthScheme] = [authScheme]

        let config = try GeoPlacesClient.Config(region: region, authSchemes: authSchemes, authSchemeResolver: resolver)
        geoPlacesClient = GeoPlacesClient(config: config)
        
        return credentialProvider
    }
    
    public func authenticateWithCredentialsProvider(credentialsProvider: CredentialsProvider, region: String) async throws -> LocationCredentialsProvider? {
        let credentialProvider = LocationCredentialsProvider(credentialsProvider: credentialsProvider)
        credentialProvider.setRegion(region: region)
        locationCredentialsProvider = credentialProvider
        amazonLocationClient = AmazonLocationClient(locationCredentialsProvider: credentialProvider)
        return credentialProvider
    }
    
    public func getLocationClient() -> AmazonLocationClient?
    {
        return amazonLocationClient
    }
    
    public func getGeoPlacesClient() -> GeoPlacesClient?
    {
        return geoPlacesClient
    }
}
