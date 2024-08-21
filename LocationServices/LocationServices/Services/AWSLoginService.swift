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

protocol AWSLoginServiceProtocol {
    var delegate: AWSLoginServiceOutputProtocol? { get set }
    func login()
    func logout(skipPolicy: Bool)
    func validate(identityPoolId: String) async throws -> Bool
}

protocol AWSLoginServiceOutputProtocol {
    func loginResult(_ result: Result<Void, Error>)
    func logoutResult(_ error: Error?)
}

extension AWSLoginServiceOutputProtocol {
    func loginResult(_ result: Result<Void, Error>) {}
    func logoutResult(_ error: Error?) {}
}

public struct CognitoToken: Codable {
    public let accessToken: String
    public let expiresIn: Int
    public let idToken: String
    public let refreshToken: String
    public let tokenType: String
    
    public init(accessToken: String, expiresIn: Int, idToken: String, refreshToken: String, tokenType: String) {
        self.accessToken = accessToken
        self.expiresIn = expiresIn
        self.idToken = idToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
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
            let credential = try decoder.decode(CognitoToken.self, from: jsonData)
            return credential
        } catch {
            print("Error decoding JSON to CognitoToken: \(error)")
            return nil
        }
    }
}

final class AWSLoginService: NSObject, AWSLoginServiceProtocol, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return (UIApplication.shared.delegate as? AppDelegate)!.navigationController!.view.window!
    }
    
    
    enum Constants {
        static let awsCognitoIdentityKey = "AWSCognitoIdentityValidationKey"
    }
    
    private static var awsLoginService = AWSLoginService()
    var delegate: AWSLoginServiceOutputProtocol?
    private var error: Error?
    weak var viewController: UIViewController?
    
    private override init() {
        
    }

    public static func `default`() -> AWSLoginService {
        return awsLoginService
    }
     
    func login() {
        guard let navigationContoller = (UIApplication.shared.delegate as? AppDelegate)?.navigationController,
        let customModel = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) else { return }
        
        let redirectUri = "amazonlocationdemo://signin/"
        let urlString = "https://\(customModel.userDomain)/login?client_id=\(customModel.userPoolClientId)&response_type=code&identity_provider=COGNITO&redirect_uri=\(redirectUri)"
        
        if let url = URL(string: urlString) {
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "amazonlocationdemo") { callbackURL, error in
                if let callbackURL = callbackURL {
                    // Handle the redirect, process the code
                    if let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                        .queryItems?
                        .first(where: { $0.name == "code" })?.value {
                        print("Authorization code: \(code)")
                        self.fetchTokens(code: code)
                    }
                } else if let error = error {
                    print("Error during authentication: \(error.localizedDescription)")
                    self.delegate?.loginResult(.failure(error))
                }
                
            }
            session.presentationContextProvider = self
            session.start()
        }
        
//        let hostedUIOptions = HostedUIOptions(scopes: ["openid", "email", "profile"], federationProviderName: "LoginWithAmazon")
//        AWSMobileClient.default().showSignIn(navigationController: navigationContoller, hostedUIOptions: hostedUIOptions) { (userState, error) in
//            if let error = error as? AWSMobileClientError {
//                print(error.localizedDescription)
//            }
//            if let userState = userState {
//                print("Status: \(userState.rawValue)")
//                
//                AWSMobileClient.default().getUserAttributes { (attributes, error) in
//                    if let error = error {
//                        print("Error getting user attributes: \(error.localizedDescription)")
//                        return
//                    }
//
//                    print(attributes)
//                }
//
//                self.getIdentityId(oldIdentityId: AWSMobileClient.default().identityId) { task in
//                    if let error = task.error {
//                        self.delegate?.loginResult(.failure(error))
//                        print("Error: \(error.localizedDescription) \((error as NSError).userInfo)")
//                    }
//                    if let result = task.result {
//                        UserDefaultsHelper.save(value: AWSMobileClient.default().identityId, key: .signedInIdentityId)
//                        UserDefaultsHelper.setAppState(state: .loggedIn)
//                        
//                        self.delegate?.loginResult(.success(()))
//                        print("Cognito Identity Id: \(result)")
//                    }
//                    
//                    
//                    self.updateAWSServicesCredentials()
//                    
//                    if let result = task.result {
//                        NotificationCenter.default.post(name: Notification.authorizationStatusChanged, object: self, userInfo: nil)
//                    }
//                
//                    self.attachPolicy()
//
//                }
//            }
//        }
    }
    
    func fetchTokens(code: String) {
        guard let customModel = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) else { return }
        
        let tokenUrl = URL(string: "https://\(customModel.userDomain)/oauth2/token")!
        var request = URLRequest(url: tokenUrl)
        request.httpMethod = "POST"

        var body = URLComponents(string: "")!
        body.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "client_id", value: customModel.userPoolClientId),
            URLQueryItem(name: "redirect_uri", value: "amazonlocationdemo://signin/"),
            URLQueryItem(name: "code", value: code)
        ]
        
        request.httpBody = body.query?.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching tokens: \(error?.localizedDescription ?? "No data")")
                return
            }

            if let jsonString = String(data: data, encoding: .utf8),  let cognitoToken = CognitoToken.decodeCognitoToken(jsonString: jsonString) {
                print("Received tokens: \(jsonString)")
                Task {
                    do {
                    try await self.updateAWSServicesToken(cognitoToken: cognitoToken)
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                        self.delegate?.loginResult(.failure(error))
                    }
                }
            }

        }.resume()
    }
    
    func refreshTokens(userDomain: String, userPoolClientId: String, refreshToken: String) {
        let tokenUrl = URL(string: "https://\(userDomain)/oauth2/token")!
        var request = URLRequest(url: tokenUrl)
        request.httpMethod = "POST"
        
        var body = URLComponents(string: "")!
        body.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "client_id", value: userPoolClientId),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        request.httpBody = body.query?.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error refreshing tokens: \(error?.localizedDescription ?? "No data")")
                return
            }
            
            // Handle the received tokens
            if let jsonString = String(data: data, encoding: .utf8),  let cognitoToken = CognitoToken.decodeCognitoToken(jsonString: jsonString) {
                print("Received tokens: \(jsonString)")
                Task {
                    do {
                    try await self.updateAWSServicesToken(cognitoToken: cognitoToken)
                    self.attachPolicy()
                    self.delegate?.loginResult(.success(()))
                    NotificationCenter.default.post(name: Notification.authorizationStatusChanged, object: self, userInfo: nil)
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                        self.delegate?.loginResult(.failure(error))
                    }
                }
            }
        }.resume()
    }


    
//    private func getIdentityId(oldIdentityId: String? = nil, retriesCount: Int = 1, completion: @escaping (AWSTask<NSString>)->()) {
//        let maxRetries = 3
//        
//        AWSMobileClient.default().getIdentityId().continueWith { [weak self] task in
//            let taskResult: String?
//            if let result = task.result {
//                taskResult = String(result)
//            } else {
//                taskResult = nil
//            }
//            
//            if (taskResult == nil || taskResult == oldIdentityId) && retriesCount < maxRetries {
//                self?.getIdentityId(oldIdentityId: oldIdentityId, retriesCount: retriesCount, completion: completion)
//            } else {
//                completion(task)
//            }
//            
//            return nil
//        }
//    }
    
    func logout(skipPolicy: Bool = false) {
        let isPolicyAttached = UserDefaultsHelper.get(for: Bool.self, key: .attachedPolicy) ?? false
        if isPolicyAttached && !skipPolicy {
            detachPolicy { [weak self] result in
                //we shouldn't prevent user from logout if detach policy failed. If policy has been corrupted then user won't be able to sign out.
                self?.awsLogout()
            }
        } else {
            self.awsLogout()
        }
        //set initial state
        UserDefaultsHelper.setAppState(state: .customAWSConnected)
        UserDefaultsHelper.removeObject(for: .signedInIdentityId)
        Task {
            try await self.updateAWSServicesToken()
        }
        NotificationCenter.default.post(name: Notification.authorizationStatusChanged, object: self, userInfo: nil)
        self.delegate?.logoutResult(nil)
    }
    
    private func awsLogout() {
//        AWSMobileClient.default().signOut { error in
//            if let error = error {
//                print ("Error during signOut: \(error.localizedDescription)")
//                
//                self.error = error
//                self.delegate?.logoutResult(error)
//                
//            } else {
//                print ("Successful log out.")
//                
//                // clear the cached credentials
//                AWSMobileClient.default().clearCredentials()
//                AWSMobileClient.default().clearKeychain()
//                print("properly cleared credentials and keychain")
//
//                // set initial state
//                UserDefaultsHelper.setAppState(state: .customAWSConnected)
//                UserDefaultsHelper.removeObject(for: .signedInIdentityId)
//                
//                self.updateAWSServicesCredentials()
//                
//                NotificationCenter.default.post(name: Notification.authorizationStatusChanged, object: self, userInfo: nil)
//                self.delegate?.logoutResult(nil)
//            }
//        }
    }
    
//    func createAWSConfiguration(with configurationModel: CustomConnectionModel) -> [String: Any] {
//        let config: [String: Any] = [
//            "UserAgent": "aws-amplify-cli/0.1.0",
//            "Version": "0.1.0",
//            "IdentityManager": [
//                "Default": [:]
//            ],
//            "CredentialsProvider": [
//                "CognitoIdentity": [
//                    "Default": [
//                        "PoolId": "\(configurationModel.identityPoolId)",
//                        "Region": "\(configurationModel.region)"
//                    ]
//                ]
//            ],
//            "CognitoUserPool": [
//                "Default": [
//                    "PoolId": "\(configurationModel.userPoolId)",
//                    "AppClientId": "\(configurationModel.userPoolClientId)",
//                    "Region": "\(configurationModel.region)"
//                ]
//            ],
//            "Auth": [
//                "Default": [
//                    "OAuth": [
//                      "WebDomain": "\(configurationModel.userDomain)",
//                      "AppClientId": "\(configurationModel.userPoolClientId)",
//                      "SignInRedirectURI": "amazonlocationdemo://signin/",
//                      "SignOutRedirectURI": "amazonlocationdemo://signout/",
//                      "Scopes": [
//                        "email",
//                        "openid",
//                        "profile"
//                      ]
//                    ]
//                  ]
//            ]
//        ]
//        
//        return config
//    }
    
    func getAWSConfigurationModel() -> CustomConnectionModel? {
        var defaultConfiguration: CustomConnectionModel? = nil
        // default configuration
        if let identityPoolId = Bundle.main.object(forInfoDictionaryKey: "IdentityPoolId") as? String,
           let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String,
           let region = Bundle.main.object(forInfoDictionaryKey: "AWSRegion") as? String{
            defaultConfiguration = CustomConnectionModel(identityPoolId: identityPoolId, userPoolClientId: "", userPoolId: "", userDomain: "", webSocketUrl: "", apiKey: apiKey, region: region)
        }

        // custom configuration
        let customConfiguration = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect)
        
        return customConfiguration ?? defaultConfiguration
    }
    
    func attachPolicy(completion: ((Result<Void, Error>)->())? = nil) {
        let isPolicyAttached = UserDefaultsHelper.get(for: Bool.self, key: .attachedPolicy) ?? false
        guard !isPolicyAttached else {
            completion?(.success(()))
            return
        }
            
//        let attachPolicyRequest = AWSIoTAttachPolicyRequest()!
//        attachPolicyRequest.target = AWSMobileClient.default().identityId
//        attachPolicyRequest.policyName = "AmazonLocationIotPolicy"
//        AWSIoT(forKey: "default").attachPolicy(attachPolicyRequest).continueWith(block: { task in
//            if let error = task.error {
//                print("Failed: [\(error)]")
//                completion?(.failure(error))
//            } else  {
//                UserDefaultsHelper.save(value: true, key: .attachedPolicy)
//                print("result: [\(String(describing: task.result))]")
//                completion?(.success(()))
//            }
//            return nil
//        })
    }
    
    private func detachPolicy(completion: @escaping (Result<Any, Error>)->()) {
//        let attachPolicyRequest = AWSIoTDetachPolicyRequest()!
//        attachPolicyRequest.target = AWSMobileClient.default().identityId
//        attachPolicyRequest.policyName = "AmazonLocationIotPolicy"
//        
//        AWSIoT(forKey: "default").detachPolicy(attachPolicyRequest).continueWith(block: { task in
//            if let error = task.error {
//                print("Failed: [\(error)]")
//                completion(.failure(error))
//            } else  {
//                UserDefaultsHelper.save(value: false, key: .attachedPolicy)
//                print("result: [\(String(describing: task.result))]")
//                completion(.success(task.result as Any))
//            }
//            return nil
//        })
    }
   
    
    func validate(identityPoolId: String) async throws -> Bool {
        let id = try await getAWSIdentityId(identityPoolId: identityPoolId)
        if id.identityId != nil  {
            return true
        }
        return false
    }
    
    private func createValidationIdentity(identityPoolId: String) {
//        let credentialProvider = AWSCognitoCredentialsProvider(regionType: identityPoolId.toRegionType(), identityPoolId: identityPoolId)
//        
//        guard let configuration = AWSServiceConfiguration(region: identityPoolId.toRegionType(), credentialsProvider: credentialProvider) else { return }
//        
//        AWSCognitoIdentity.register(with: configuration, forKey: Constants.awsCognitoIdentityKey)
    }
    
//    private func getValidationIdentity() -> AWSCognitoIdentity {
//        return AWSCognitoIdentity(forKey: Constants.awsCognitoIdentityKey)
//    }
    
    func updateAWSServicesToken(cognitoToken: CognitoToken? = nil) async throws {
        guard let customModel = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) else { return }
        do {
            if cognitoToken != nil {
                KeyChainHelper.save(value: CognitoToken.encodeCognitoToken(cognitoToken: cognitoToken!)!, key: .cognitoToken)
                let identityPoolId = customModel.identityPoolId
                let id = try await getAWSIdentityId(identityPoolId: identityPoolId)
                let region = identityPoolId.toRegionString()
                let client = try AWSCognitoIdentity.CognitoIdentityClient(region: region)
                let logins = ["cognito-idp.\(region).amazonaws.com/\(customModel.userPoolId)": cognitoToken!.idToken]
                let input = GetCredentialsForIdentityInput(identityId: id.identityId, logins: logins)
                let credentialsOutput = try await client.getCredentialsForIdentity(input: input)
                if let credentials = credentialsOutput.credentials {
                    let cognitoCredentials = CognitoCredentials(identityPoolId: credentialsOutput.identityId!, accessKeyId: credentials.accessKeyId!, secretKey: credentials.secretKey!, sessionToken: credentials.sessionToken!, expiration: credentials.expiration!)
                    try await updateAWSServicesCredentials(cognitoCredentials: cognitoCredentials)
                    self.attachPolicy()
                    UserDefaultsHelper.save(value: id.identityId, key: .signedInIdentityId)
                    UserDefaultsHelper.setAppState(state: .loggedIn)
                    self.delegate?.loginResult(.success(()))
                    NotificationCenter.default.post(name: Notification.authorizationStatusChanged, object: self, userInfo: nil)
                }
            }
            else {
                KeyChainHelper.delete(key: .cognitoToken)
                try await updateAWSServicesCredentials(cognitoCredentials: nil)
            }
        }
        catch {
            throw error
        }
//        guard let configurationModel = self.getAWSConfigurationModel() else {
//            print("Can't read default configuration from awsconfiguration.json")
//            return
//        }
        // Now that we have refreshed to the latest itendityId qw need to make sure
        // that AWSServiceManager promotes the latest credentials to services such as AWSLocation
//        let credentialsProvider = AWSCognitoCredentialsProvider(
//            regionType: configurationModel.identityPoolId.toRegionType(),
//            identityPoolId: configurationModel.identityPoolId,
//            identityProviderManager: AWSMobileClient.default()
//        )
//        
//        let locationConfig = AWSServiceConfiguration(region: configurationModel.identityPoolId.toRegionType(), credentialsProvider: credentialsProvider)
//        
//        AWSLocation.register(with: locationConfig!, forKey: "default")
//        AWSIoT.register(with: locationConfig!, forKey: "default")
//        
//        AWSServiceManager.default().defaultServiceConfiguration = locationConfig
    }
    
    func updateAWSServicesCredentials(cognitoCredentials: CognitoCredentials? = nil) async throws {
        guard let customModel = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) else { return }
        if cognitoCredentials != nil {
            do {
                let credentialsProvider = try CredentialsProvider(source: .cached(source: CredentialsProvider(source: .static(accessKey: cognitoCredentials!.accessKeyId, secret: cognitoCredentials!.secretKey, sessionToken: cognitoCredentials!.sessionToken))))
                try await CognitoAuthHelper.initialise(credentialsProvider: credentialsProvider, region: customModel.region)
                KeyChainHelper.save(value: CognitoCredentials.encodeCognitoCredentials(credential: cognitoCredentials!)!, key: .cognitoCredentials)
            }
            catch {
                throw error
            }
        }
        else {
            KeyChainHelper.delete(key: .cognitoCredentials)
        }
    }
    
    public func getAWSIdentityId(identityPoolId: String) async throws -> GetIdOutput {
        do {
            let cognitoIdentityClient = try AWSCognitoIdentity.CognitoIdentityClient(region: identityPoolId.toRegionString())
            let idInput = GetIdInput(identityPoolId: identityPoolId)
            let identity = try await cognitoIdentityClient.getId(input: idInput)
            return identity
        } catch {
            throw error
        }
    }
}

