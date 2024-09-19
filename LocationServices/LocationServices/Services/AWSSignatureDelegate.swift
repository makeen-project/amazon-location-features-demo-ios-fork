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
        
        if apiKey != nil && region != nil {
             return URL(string: "\(url)?key=\(apiKey!)") ?? url
         }
        else if let cognitoProvider = CognitoAuthHelper.default().locationCredentialsProvider?.getCognitoProvider(), region != nil {
             var signedURL: URL = url
             let semaphore = DispatchSemaphore(value: 0)
             Task {
                 try await cognitoProvider.refreshCognitoCredentialsIfExpired()
                 let cognitoCredentials: CognitoCredentials? = cognitoProvider.getCognitoCredentials()
                 let awsSigner = AWSSignerV4(credentials: cognitoCredentials!, serviceName: "geo", region: self.region!)
                 signedURL = awsSigner.signURL(url: url, expires: .hours(1))
                 semaphore.signal()
             }
             semaphore.wait()
             return signedURL
         }
        return url
    }
}
