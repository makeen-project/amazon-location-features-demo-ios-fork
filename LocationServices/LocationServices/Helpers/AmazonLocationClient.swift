//
//  AmazonLocationClient.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocation
import SmithyIdentity
import SmithyIdentityAPI
import AWSSDKIdentity

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public struct HTTPHeaders {
    private var headers: [String: String]

    public init() {
        headers = [:]
    }

    mutating func add(name: String, value: String) {
        headers[name] = value
    }

    mutating func remove(name: String) {
        headers.removeValue(forKey: name)
    }

    func value(forName name: String) -> String? {
        return headers[name]
    }

    func allHeaders() -> [String: String] {
        return headers
    }
}

public class AmazonLocationClient {
    public let locationProvider: LocationCredentialsProvider
    public var locationClient: LocationClient?
    
    public init(locationCredentialsProvider: LocationCredentialsProvider) {
        self.locationProvider = locationCredentialsProvider
    }
    
    public func initialiseLocationClient() async throws {
        if let credentials = locationProvider.getCognitoProvider()?.getCognitoCredentials() {
            
            try await setLocationClient(accessKey: credentials.accessKeyId, secret: credentials.secretKey, expiration: credentials.expiration, sessionToken: credentials.sessionToken)
        }
        else if let credentialsProvider = locationProvider.getCustomCredentialsProvider() {
            
            let credentials = try await credentialsProvider.getCredentials()
            
            if let accessKey = credentials.getAccessKey(), let secret = credentials.getSecret() {
                try await setLocationClient(accessKey: accessKey, secret: secret, expiration: credentials.getExpiration(), sessionToken: credentials.getSessionToken())
            }
        }
    }
    
    public func setLocationClient(accessKey: String, secret: String, expiration: Date?, sessionToken: String?) async throws {
        let identity = AWSCredentialIdentity(accessKey: accessKey, secret: secret, expiration: expiration, sessionToken: sessionToken)
        let resolver =  try StaticAWSCredentialIdentityResolver(identity)
        let cachedResolver: CachedAWSCredentialIdentityResolver? = try CachedAWSCredentialIdentityResolver(source: resolver, refreshTime: 3540)
        let clientConfig = try await LocationClient.LocationClientConfiguration(awsCredentialIdentityResolver: cachedResolver, region: locationProvider.getRegion(), signingRegion: locationProvider.getRegion())
        
        self.locationClient = LocationClient(config: clientConfig)
    }
}

public extension AmazonLocationClient {
    static func defaultCognito() -> AmazonLocationClient? {
        return CognitoAuthHelper.default().amazonLocationClient
    }
    
    static func defaultApi() -> AmazonLocationClient? {
        return ApiAuthHelper.default().amazonLocationClient
    }
}
