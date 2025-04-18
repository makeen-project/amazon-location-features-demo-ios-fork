//
//  AWSLoginService.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSLocation
import AWSIoT
import UIKit
import AWSCognitoIdentity
import SafariServices
import AuthenticationServices
import AwsCommonRuntimeKit
import SmithyIdentity
import AwsCMqtt

protocol AWSAuthServiceProtocol {
}

public struct CognitoToken: Codable {
    public let accessToken: String
    public let expiresIn: Int
    public let idToken: String
    public let refreshToken: String
    public let tokenType: String
    public let issueDate: Date
    
    public init(accessToken: String, expiresIn: Int, idToken: String, refreshToken: String, tokenType: String, issueDate: Date) {
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.idToken = idToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.issueDate = issueDate
    }
    
    public static func encodeCognitoToken(cognitoToken: CognitoToken) -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            let jsonData = try encoder.encode(cognitoToken)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            print("Error encoding CognitoToken to JSON: \(error)")
            return nil
        }
    }
    
    public static func decodeCognitoToken(jsonString: String) -> CognitoToken? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Invalid JSON string")
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        do {
            let token = try decoder.decode(CognitoToken.self, from: jsonData)
            return token
        } catch {
            print("Error decoding JSON to CognitoToken: \(error)")
            return nil
        }
    }
}

final class AWSAuthService: NSObject, AWSAuthServiceProtocol, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return (UIApplication.shared.delegate as? AppDelegate)!.navigationController!.view.window!
    }
    
    
    enum Constants {
        static let awsCognitoIdentityKey = "AWSCognitoIdentityValidationKey"
    }
    
    private static var awsAuthService = AWSAuthService()
    //var delegate: AWSLoginServiceOutputProtocol?
    private var error: Error?
    weak var viewController: UIViewController?
    
    private override init() {
        
    }

    public static func `default`() -> AWSAuthService {
        return awsAuthService
    }
}

