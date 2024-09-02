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

protocol AWSLoginServiceProtocol {
    var delegate: AWSLoginServiceOutputProtocol? { get set }
    func login() async throws
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
     
    func login() async throws {
        guard let customModel = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) else {
            throw NSError(domain: "CustomConnectionModelError", code: -1, userInfo: [NSLocalizedDescriptionKey: "CustomConnectionModel not found"])
        }

        let redirectUri = "amazonlocationdemo://signin/"
        let urlString = "https://\(customModel.userDomain)/login?client_id=\(customModel.userPoolClientId)&response_type=code&identity_provider=COGNITO&redirect_uri=\(redirectUri)"
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "URLError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid login URL"])
        }
        DispatchQueue.main.async {
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "amazonlocationdemo") { callbackURL, error in
                if let error = error {
                    Task {
                        self.delegate?.loginResult(.failure(error))
                    }
                    return
                }
                
                if let callbackURL = callbackURL,
                   let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                    .queryItems?
                    .first(where: { $0.name == "code" })?.value {
                    print("Authorization code: \(code)")
                    Task {
                        do {
                            try await self.fetchTokens(code: code)
                        } catch {
                            print("Error fetching tokens: \(error.localizedDescription)")
                            self.delegate?.loginResult(.failure(error))
                        }
                    }
                }
            }
            
            session.presentationContextProvider = self
            session.start()
        }
    }
    
    func fetchTokens(code: String) async throws {
        guard let customModel = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) else {
            throw NSError(domain: "CustomConnectionModelError", code: -1, userInfo: [NSLocalizedDescriptionKey: "CustomConnectionModel not found"])
        }
        
        let tokenUrl = URL(string: "https://\(customModel.userDomain)/oauth2/token")!
        var request = URLRequest(url: tokenUrl)
        request.httpMethod = "POST"
        
        var body = URLComponents()
        body.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "client_id", value: customModel.userPoolClientId),
            URLQueryItem(name: "redirect_uri", value: "amazonlocationdemo://signin/"),
            URLQueryItem(name: "code", value: code)
        ]
        
        request.httpBody = body.query?.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "HTTPError", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            if let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String:AnyObject] {
                
                let cognitoToken = CognitoToken(accessToken: json["access_token"] as! String, expiresIn: json["expires_in"] as! Int, idToken: json["id_token"] as! String, refreshToken: json["refresh_token"] as! String, tokenType: json["token_type"] as! String, issueDate: Date())
                try await self.updateAWSServicesToken(cognitoToken: cognitoToken)
                self.delegate?.loginResult(.success(()))
                NotificationCenter.default.post(name: Notification.authorizationStatusChanged, object: self, userInfo: nil)
            }
        } catch {
            print("Error fetching tokens: \(error.localizedDescription)")
            self.delegate?.loginResult(.failure(error))
        }
    }


    func refreshTokens(userDomain: String, userPoolClientId: String, refreshToken: String) async throws {
        let tokenUrl = URL(string: "https://\(userDomain)/oauth2/token")!
        var request = URLRequest(url: tokenUrl)
        request.httpMethod = "POST"
        
        var body = URLComponents()
        body.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "client_id", value: userPoolClientId),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        request.httpBody = body.query?.data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NSError(domain: "", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil)
            }
            
            // Handle the received tokens
            if let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String:AnyObject]
            {
                let cognitoToken = CognitoToken(accessToken: json["access_token"] as! String, expiresIn: json["expires_in"] as! Int, idToken: json["id_token"] as! String, refreshToken: refreshToken, tokenType: json["token_type"] as! String, issueDate: Date())
                try await self.updateAWSServicesToken(cognitoToken: cognitoToken)
                self.delegate?.loginResult(.success(()))
                NotificationCenter.default.post(name: Notification.authorizationStatusChanged, object: self, userInfo: nil)
            }
        } catch {
            print("Error refreshing tokens: \(error.localizedDescription)")
            self.delegate?.loginResult(.failure(error))
        }
    }
    
    func logout(skipPolicy: Bool = false) {
        let isPolicyAttached = UserDefaultsHelper.get(for: Bool.self, key: .attachedPolicy) ?? false
        if isPolicyAttached && !skipPolicy {
            Task {
                try await detachPolicy()
            }
            self.awsLogout()
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
    }
    
    
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
    
    func attachPolicy(cognitoCredentials: CognitoCredentials) async throws {
        do {
            guard let customModel = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) else { return }
//            let isPolicyAttached = UserDefaultsHelper.get(for: Bool.self, key: .attachedPolicy) ?? false
//            guard !isPolicyAttached else {
//                return
//            }
            let identityPoolId = customModel.identityPoolId
            let id = try await getAWSIdentityId(identityPoolId: identityPoolId)
            let resolver: StaticAWSCredentialIdentityResolver? = try StaticAWSCredentialIdentityResolver(AWSCredentialIdentity(accessKey: cognitoCredentials.accessKeyId, secret: cognitoCredentials.secretKey, expiration: cognitoCredentials.expiration, sessionToken: cognitoCredentials.sessionToken))
            let iotConfiguration = try await IoTClient.IoTClientConfiguration(awsCredentialIdentityResolver: resolver, region: identityPoolId.toRegionString(), signingRegion: identityPoolId.toRegionString())
            let iotClient = IoTClient(config: iotConfiguration)
            let input = AttachPolicyInput(policyName: "AmazonLocationIotPolicy", target: id)
            _ = try await iotClient.attachPolicy(input: input)
            UserDefaultsHelper.save(value: true, key: .attachedPolicy)
            print("Attached policy successully...")
        }
        catch {
            print(error)
            throw error
        }
    }
    
    private func detachPolicy() async throws {
        guard let customModel = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) else { return }
        let identityPoolId = customModel.identityPoolId
        let id = try await getAWSIdentityId(identityPoolId: identityPoolId)
        let iotClient = try IoTClient(region: identityPoolId.toRegionString())
        let input = DetachPolicyInput(policyName: "AmazonLocationIotPolicy", target: id)
        _ = try await iotClient.detachPolicy(input: input)
        UserDefaultsHelper.save(value: false, key: .attachedPolicy)
        print("Detached policy successully...")
    }
   
    
    func validate(identityPoolId: String) async throws -> Bool {
        let id = try await getAWSIdentityId(identityPoolId: identityPoolId)
        if id != nil  {
            return true
        }
        return false
    }
    
    private func createValidationIdentity(identityPoolId: String) {
    }
    
    func updateAWSServicesToken(cognitoToken: CognitoToken? = nil) async throws {
        guard let customModel = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) else { return }
        do {
            if cognitoToken != nil {
                KeyChainHelper.save(value: CognitoToken.encodeCognitoToken(cognitoToken: cognitoToken!)!, key: .cognitoToken)
                print("Saved cognito token successully...")
                let identityPoolId = customModel.identityPoolId
                let id = try await getAWSIdentityId(identityPoolId: identityPoolId)
                let region = identityPoolId.toRegionString()
                let client = try AWSCognitoIdentity.CognitoIdentityClient(region: region)
                let logins = ["cognito-idp.\(region).amazonaws.com/\(customModel.userPoolId)": cognitoToken!.idToken]
                let input = GetCredentialsForIdentityInput(identityId: id, logins: logins)
                let credentialsOutput = try await client.getCredentialsForIdentity(input: input)
                
                if let credentials = credentialsOutput.credentials {
                    let cognitoCredentials = CognitoCredentials(identityPoolId: credentialsOutput.identityId!, accessKeyId: credentials.accessKeyId!, secretKey: credentials.secretKey!, sessionToken: credentials.sessionToken!, expiration: credentials.expiration!)
                    try await updateAWSServicesCredentials(cognitoCredentials: cognitoCredentials)
                    try await self.attachPolicy(cognitoCredentials: cognitoCredentials)
                    UserDefaultsHelper.save(value: id, key: .signedInIdentityId)
                    UserDefaultsHelper.setAppState(state: .loggedIn)
                    self.delegate?.loginResult(.success(()))
                    NotificationCenter.default.post(name: Notification.authorizationStatusChanged, object: self, userInfo: nil)
                }
            }
            else {
                _ = KeyChainHelper.delete(key: .cognitoToken)
                try await updateAWSServicesCredentials(cognitoCredentials: nil)
            }
        }
        catch {
            throw error
        }
    }
    public var credentialsProvider: CredentialsProvider?
    func updateAWSServicesCredentials(cognitoCredentials: CognitoCredentials? = nil) async throws {
        guard let customModel = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) else { return }
        if cognitoCredentials != nil {
            do {
                credentialsProvider = try CredentialsProvider(source: .cached(source: CredentialsProvider(source: .static(accessKey: cognitoCredentials!.accessKeyId, secret: cognitoCredentials!.secretKey, sessionToken: cognitoCredentials!.sessionToken))))
                try await CognitoAuthHelper.initialise(credentialsProvider: credentialsProvider!, region: customModel.region)
                KeyChainHelper.save(value: CognitoCredentials.encodeCognitoCredentials(credential: cognitoCredentials!)!, key: .cognitoCredentials)
                print("Saved cognito credentials...")
                try await CognitoAuthHelper.default().amazonLocationClient?.setLocationClient(accessKey: cognitoCredentials!.accessKeyId, secret: cognitoCredentials!.secretKey, expiration: cognitoCredentials!.expiration, sessionToken: cognitoCredentials!.sessionToken)
            }
            catch {
                throw error
            }
        }
        else {
            _ = KeyChainHelper.delete(key: .cognitoCredentials)
            print("Deleted cognito credentials...")
        }
    }
    
    public func isCognitoLoginExpired() -> Bool {
        if let credentialsString = KeyChainHelper.get(key: .cognitoCredentials),
           let cognitoCredentials = CognitoCredentials.decodeCognitoCredentials(jsonString: credentialsString),
           let expiration = cognitoCredentials.expiration,
           expiration > Date() {
            return false
        }
        return true
    }
    
    public func refreshLoginIfExpired() async throws {
        let isExpired = isCognitoLoginExpired()
        if isExpired {
            guard let customModel = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect),
                  let tokenString = KeyChainHelper.get(key: .cognitoToken),
                  let cognitoToken = CognitoToken.decodeCognitoToken(jsonString: tokenString)
            else { return }
            identity = nil
            _ = KeyChainHelper.delete(key: .cognitoCredentials)
            try await refreshTokens(userDomain: customModel.userDomain, userPoolClientId: customModel.userPoolClientId, refreshToken: cognitoToken.refreshToken)
        }
    }
    
    var identity: GetIdOutput?
    
    public func getAWSIdentityId(identityPoolId: String) async throws -> String? {
        do {
            let region = identityPoolId.toRegionString()
            var idInput = GetIdInput(identityPoolId: identityPoolId)
            var cognitoIdentityClient = try AWSCognitoIdentity.CognitoIdentityClient(region: region)
            
            if let customModel = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect),
               let tokenString = KeyChainHelper.get(key: .cognitoToken),
               let credentialsString = KeyChainHelper.get(key: .cognitoCredentials),
               let cognitoToken = CognitoToken.decodeCognitoToken(jsonString: tokenString),
               let cognitoCredentials = CognitoCredentials.decodeCognitoCredentials(jsonString: credentialsString) {
                try await refreshLoginIfExpired()
                if credentialsProvider == nil {
                    credentialsProvider = try CredentialsProvider(source: .cached(source: CredentialsProvider(source: .static(accessKey: cognitoCredentials.accessKeyId, secret: cognitoCredentials.secretKey, sessionToken: cognitoCredentials.sessionToken))))
                }
                if let identityId = UserDefaultsHelper.get(for: String.self, key: .signedInIdentityId) {
                print("Returning saved aws identity...")
                return identityId
                }
                let resolver: StaticAWSCredentialIdentityResolver? = try StaticAWSCredentialIdentityResolver(AWSCredentialIdentity(accessKey: cognitoCredentials.accessKeyId, secret: cognitoCredentials.secretKey, expiration: cognitoCredentials.expiration, sessionToken: cognitoCredentials.sessionToken))
                
                let config = try await  CognitoIdentityClient.CognitoIdentityClientConfiguration(awsCredentialIdentityResolver: resolver, region: region, signingRegion: region)
                
                cognitoIdentityClient = AWSCognitoIdentity.CognitoIdentityClient(config: config)
                let logins = ["cognito-idp.\(region).amazonaws.com/\(customModel.userPoolId)": cognitoToken.idToken]
                idInput = GetIdInput(identityPoolId: identityPoolId, logins: logins)
            }
            
            let identity = try await cognitoIdentityClient.getId(input: idInput)
            print("Generated new aws identity...")
            return identity.identityId!
        } catch {
            print("Error generating aws identity: \(error)")
            throw error
        }
    }
}

