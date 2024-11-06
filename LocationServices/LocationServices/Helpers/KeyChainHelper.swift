//
//  KeyChainHelper.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import KeychainSwift

enum KeyChainType: String {
    case amazonLocationAPIKey
    case awsRegion
    case cognitoCredentials
    case cognitoToken
}

final class KeyChainHelper {
    static let keychain = KeychainSwift()
    
    static func save(value:String, key: KeyChainType) {
        keychain.set(value, forKey: key.rawValue)
    }
    
    static func get(key: KeyChainType) -> String? {
        return keychain.get(key.rawValue)
    }
    
    static func delete(key: KeyChainType) -> Bool {
        return keychain.delete(key.rawValue)
    }
}
