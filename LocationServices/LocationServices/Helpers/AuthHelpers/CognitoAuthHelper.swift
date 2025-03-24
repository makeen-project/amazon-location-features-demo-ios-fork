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
import AWSCognitoIdentity

public class CognitoAuthHelper {

    private static var _sharedInstance: CognitoAuthHelper?
    var locationClient: LocationClient?
    var identityPoolId: String?
    private init() {
    }
    
    static func initialise(identityPoolId: String) async throws {
        _sharedInstance = CognitoAuthHelper()
        if let identityPoolId = GeneralHelper.getAWSConfigurationModel()?.identityPoolId {
            
            let authHelper = try await AuthHelper.withIdentityPoolId(identityPoolId: identityPoolId)
            let config = authHelper.getLocationClientConfig()
            let client = LocationClient(config: config)
            _sharedInstance?.locationClient = client
            _sharedInstance?.identityPoolId = identityPoolId
        }
    }
    
    private static var cognitoIdentityClient: CognitoIdentityClient?
    static func getAWSIdentityId(identityPoolId: String) async throws -> GetIdOutput {
        do {
            let region = identityPoolId.toRegionString()
            if cognitoIdentityClient == nil {
                cognitoIdentityClient = try AWSCognitoIdentity.CognitoIdentityClient(region: region)
            }
            let idInput = GetIdInput(identityPoolId: identityPoolId)
            let identity = try await cognitoIdentityClient!.getId(input: idInput)
            return identity
        } catch {
            throw error
        }
    }
    
    static func getAWSCredentials(identityId: String, region: String) async throws -> GetCredentialsForIdentityOutput {
        do {
            if cognitoIdentityClient == nil {
                cognitoIdentityClient = try AWSCognitoIdentity.CognitoIdentityClient(region: region)
            }
            let credentialsInput = GetCredentialsForIdentityInput(identityId: identityId)
            let credentials = try await cognitoIdentityClient!.getCredentialsForIdentity(input: credentialsInput)
            return credentials
            
        } catch {
            throw error
        }
    }
    
    static func `default`() -> CognitoAuthHelper {
        return _sharedInstance!
    }
}
