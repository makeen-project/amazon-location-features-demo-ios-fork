//
//  AWSSignitureDelegate.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import AmazonLocationiOSAuthSDK
import MapLibre

class AWSSignatureV4Delegate : NSObject, MLNOfflineStorageDelegate {
    private var awsSigner: AWSSignerV4? = nil
    private var region: String? = nil
    private var apiKey: String? = nil
    
    init(amazonStaticCredentials: AmazonStaticCredentials, region: String) {
        self.awsSigner = AWSSignerV4(credentials: amazonStaticCredentials, serviceName: "geo", region: region)
        super.init()
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
        
        if awsSigner != nil {
            let signedURL = awsSigner!.signURL(url: url, expires: .hours(1))
            return signedURL
        }
        else if apiKey != nil && region != nil {
            return URL(string: "\(url)?key=\(apiKey!)") ?? url
        }
        return url
    }
}
