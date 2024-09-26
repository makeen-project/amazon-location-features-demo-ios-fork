//
//  AWSSignitureDelegate.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import MapLibre
import AwsCommonRuntimeKit

class AWSSignatureV4Delegate : NSObject, MLNOfflineStorageDelegate {
    private var region: String? = nil
    private var apiKey: String? = nil
    
    init(region: String) {
        super.init()
        self.region = region
    }
    
    init(apiKey: String, region: String) {
        super.init()
        self.apiKey = apiKey
        self.region = region
    }

    func offlineStorage(_ storage: MLNOfflineStorage, urlForResourceOf kind: MLNResourceKind, with url: URL) -> URL {
        if url.host?.contains("amazonaws.com") != true || url.absoluteString.contains("?key=") {
            return url
        }

        // If API Key exists, return the signed URL with the key
        if apiKey != nil && region != nil {
            return URL(string: "\(url)?key=\(apiKey!)") ?? url
        }

        // Handle Cognito credentials and sign the URL
        if let cognitoProvider = CognitoAuthHelper.default().locationCredentialsProvider?.getCognitoProvider(), region != nil {
            let signedURL = signURLWithCognito(url: url, cognitoProvider: cognitoProvider)
            return signedURL ?? url
        }

        return url
    }
    
    private func signURLWithCognito(url: URL, cognitoProvider: AmazonLocationCognitoCredentialsProvider) -> URL? {
        var signedURL: URL?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        // Perform the signing asynchronously
        Task {
            do {
                try await cognitoProvider.refreshCognitoCredentialsIfExpired()
                if let cognitoCredentials = cognitoProvider.getCognitoCredentials() {
                    let awsSigner = AWSSignerV4(credentials: cognitoCredentials, serviceName: "geo", region: self.region!)
                    signedURL = awsSigner.signURL(url: url, expires: .hours(1))
                }
            } catch {
                print("Error signing the URL: \(error)")
            }
            
            semaphore.signal()
        }
        
        // Wait for the task to complete
        semaphore.wait()
        
        return signedURL
    }
}
