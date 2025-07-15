//
//  AnalyticsCredentialsProvider.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AmazonLocationiOSAuthSDK
import AWSCognitoIdentity

class AnalyticsCredentialsProvider {
    internal var identityPoolId: String
    internal var region: String
    private var cognitoCredentials: CognitoCredentials?
    private var refreshTimer: Timer?
    
    public init(identityPoolId: String, region: String) {
        self.identityPoolId = identityPoolId
        self.region = region
    }

    public func getCognitoCredentials() -> CognitoCredentials? {
        if self.cognitoCredentials != nil && self.cognitoCredentials!.expiration! > Date() {
            return self.cognitoCredentials
        }
        else if let cognitoCredentialsString = KeyChainHelper.get(key: .analyticsCredentials), let cognitoCredentials = CognitoCredentials.decodeCognitoCredentials(jsonString: cognitoCredentialsString) {
            self.cognitoCredentials = cognitoCredentials
            return self.cognitoCredentials
        }
        return self.cognitoCredentials
    }
    
    func refreshCognitoCredentialsIfExpired() async throws {
        if let savedCredentials = getCognitoCredentials(), savedCredentials.expiration! > Date() {
            cognitoCredentials = savedCredentials
        } else {
            try? await refreshCognitoCredentials()
        }
    }
    
    func isCongnitoCredentialsExpired() -> Bool {
        if let savedCredentials = getCognitoCredentials(), savedCredentials.expiration! > Date() {
            return true
        } else {
            return false
        }
    }
    
    func refreshCognitoCredentials() async throws {
        if let cognitoCredentials = try await generateCognitoCredentials() {
            setCognitoCredentials(cognitoCredentials: cognitoCredentials)

            var timeToRefresh = 3600.0 // default to 1 hour if credentials does not have expiration field
            if (cognitoCredentials.expiration != nil) {
                timeToRefresh = cognitoCredentials.expiration!.timeIntervalSince(Date())
            }

            // timeToRefresh minus 1 minute to give some time for the actual refresh to happen
            timeToRefresh -= 60.0

            // Dispatch a timed refresh of the credentials before they expire
            // We have to copy timeToRefresh to dispatchTimeToRefresh, because you can't reference
            // a captured var in a concurrent operation, only constants
            let dispatchTimeToRefresh = timeToRefresh
            DispatchQueue.main.async {
                self.refreshTimer = Timer.scheduledTimer(timeInterval: dispatchTimeToRefresh, target: self, selector: #selector(self.dispatchRefreshCognitoCredentials), userInfo: nil, repeats: false)
            }
        }
    }
    var cognitoIdentityClient: CognitoIdentityClient?
    
    func generateCognitoCredentials() async throws  -> CognitoCredentials?
    {
        let identity = try await getAWSIdentityId()
        
        if let credentialsOutput = try await getAWSCredentials(identity: identity).credentials,
            let accessKeyId = credentialsOutput.accessKeyId,
            let secretKey = credentialsOutput.secretKey,
            let sessionToken = credentialsOutput.sessionToken,
            let expiration = credentialsOutput.expiration  {
            
            let cognitoCredentials = CognitoCredentials(identityPoolId: identityPoolId, accessKeyId: accessKeyId, secretKey: secretKey, sessionToken: sessionToken, expiration: expiration)
            return cognitoCredentials
        }
        return nil
    }
    
    func getAWSIdentityId() async throws -> GetIdOutput {
        do {
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
    
    func getAWSCredentials(identity: GetIdOutput) async throws -> GetCredentialsForIdentityOutput {
        do {
            if cognitoIdentityClient == nil {
                cognitoIdentityClient = try AWSCognitoIdentity.CognitoIdentityClient(region: region)
            }
            let credentialsInput = GetCredentialsForIdentityInput(identityId: identity.identityId)
            let credentials = try await cognitoIdentityClient!.getCredentialsForIdentity(input: credentialsInput)
            return credentials
            
        } catch {
            throw error
        }
    }
    
    @objc public func dispatchRefreshCognitoCredentials() {
        // Helper function so that we can call refreshCognitoCredentials, which is an async method,
        // from the refresh Timer selector in refreshCognitoCredentials()
        // Swift will crash if you try to target an async method with a Timer selector
        Task {
            try await self.refreshCognitoCredentials()
        }
    }
    
    private func setCognitoCredentials(cognitoCredentials: CognitoCredentials) {
        self.cognitoCredentials = cognitoCredentials
        KeyChainHelper.save(value: CognitoCredentials.encodeCognitoCredentials(credential: cognitoCredentials)!, key: .analyticsCredentials)
    }
}
