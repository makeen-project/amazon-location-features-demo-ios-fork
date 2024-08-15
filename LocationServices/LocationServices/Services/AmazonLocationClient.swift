//
//  AmazonLocationClient.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AmazonLocationiOSAuthSDK
import AWSLocation

public extension AmazonLocationClient {
    static func defaultCognito() -> AmazonLocationClient? {
        return CognitoAuthHelper.default().amazonLocationClient
    }
    
    static func defaultApi() -> AmazonLocationClient? {
        return ApiAuthHelper.default().amazonLocationClient
    }
}
