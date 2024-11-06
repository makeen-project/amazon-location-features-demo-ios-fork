//
//  CognitoAuthHelper.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSSDKIdentity
import AmazonLocationiOSAuthSDK
import AWSLocation
import AwsCommonRuntimeKit

public class CognitoAuthHelper {

    private static var _sharedInstance: CognitoAuthHelper?
    var locationClient: LocationClient?
    
    private init() {
    }
    
    static func initialise(identityPoolId: String) async throws {
        let region = identityPoolId.toRegionString()
        _sharedInstance = CognitoAuthHelper()

        if let credentialsString = KeyChainHelper.get(key: .cognitoCredentials),
           let credentials = CognitoCredentials.decodeCognitoCredentials(jsonString: credentialsString) {
            
            var resolver: StaticAWSCredentialIdentityResolver?
                let credentialsIdentity = AWSCredentialIdentity(accessKey: credentials.accessKeyId, secret: credentials.secretKey, expiration: credentials.expiration, sessionToken: credentials.sessionToken)
                resolver = try StaticAWSCredentialIdentityResolver(credentialsIdentity)
            let locationClientConfig = try await LocationClient.LocationClientConfiguration(awsCredentialIdentityResolver: resolver, region: region, signingRegion: region)
            _sharedInstance?.locationClient = LocationClient(config: locationClientConfig)
        }
    }
    
    static func `default`() -> CognitoAuthHelper {
        return _sharedInstance!
    }
}
