//
//  CustomConnectionModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

struct CustomConnectionModel: Codable {
    //identityPoolIdFormat: REGION:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    var identityPoolId: String
    var userPoolClientId: String
    var userPoolId: String
    var userDomain: String
    var webSocketUrl: String
    var apiKey: String
    
    var region: String //{
//        let regionDivider: Character = ":"
//        return String(identityPoolId.prefix(while: { $0 != regionDivider }))
//    }
}
