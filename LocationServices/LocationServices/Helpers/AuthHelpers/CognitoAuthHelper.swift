//
//  CognitoAuthHelper.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AmazonLocationiOSAuthSDK
import AWSLocation
import AWSCognitoIdentity

actor CognitoAuthHelper {
    static let shared = CognitoAuthHelper()
    
    private(set) var locationClient: LocationClient?
    private(set) var identityPoolId: String?
    private(set) var cognitoIdentityClient: CognitoIdentityClient?

    private init() {}

    func initialise() async throws {
        guard let identityPoolId = GeneralHelper.getAWSConfigurationModel()?.identityPoolId else {
            throw NSError(domain: "MissingIdentityPoolId", code: 0)
        }

        let authHelper = try await AuthHelper.withIdentityPoolId(identityPoolId: identityPoolId)
        let config = authHelper.getLocationClientConfig()
        self.locationClient = LocationClient(config: config)
        self.identityPoolId = identityPoolId
    }

    func getAWSIdentityId() async throws -> GetIdOutput {
        let region = identityPoolId?.toRegionString() ?? ""
        if cognitoIdentityClient == nil {
            cognitoIdentityClient = try AWSCognitoIdentity.CognitoIdentityClient(region: region)
        }
        let input = GetIdInput(identityPoolId: identityPoolId!)
        return try await cognitoIdentityClient!.getId(input: input)
    }

    func validate() async throws -> Bool {
        let id = try await getAWSIdentityId()
        return id.identityId != nil
    }

    func getAWSCredentials(identityId: String, region: String) async throws -> GetCredentialsForIdentityOutput {
        if cognitoIdentityClient == nil {
            cognitoIdentityClient = try AWSCognitoIdentity.CognitoIdentityClient(region: region)
        }
        let credentialsInput = GetCredentialsForIdentityInput(identityId: identityId)
        return try await cognitoIdentityClient!.getCredentialsForIdentity(input: credentialsInput)
    }
}
