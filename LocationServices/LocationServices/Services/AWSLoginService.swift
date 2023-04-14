//
//  AWSLoginService.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSMobileClientXCF
import AWSLocationXCF
import AWSIoT

protocol AWSLoginServiceProtocol {
    var delegate: AWSLoginServiceOutputProtocol? { get set }
    func login()
    func logout()
    func validate(identityPoolId: String, completion: @escaping (Result<Void, Error>)->())
}

protocol AWSLoginServiceOutputProtocol {
    func loginResult(_ result: Result<Void, Error>)
    func logoutResult(_ error: Error?)
}

extension AWSLoginServiceOutputProtocol {
    func loginResult(_ result: Result<Void, Error>) {}
    func logoutResult(_ error: Error?) {}
}

final class AWSLoginService: NSObject, AWSLoginServiceProtocol {
    enum Constants {
        static let awsCognitoIdentityKey = "AWSCognitoIdentityValidationKey"
    }
    
    var delegate: AWSLoginServiceOutputProtocol?
    private var error: Error?
    var viewController: UIViewController?
     
    func login() {
        guard let navigationContoller = (UIApplication.shared.delegate as? AppDelegate)?.navigationController else { return }
        
        let hostedUIOptions = HostedUIOptions(scopes: ["openid", "email", "profile"], federationProviderName: "LoginWithAmazon")
        
        AWSMobileClient.default().showSignIn(navigationController: navigationContoller, hostedUIOptions: hostedUIOptions) { (userState, error) in
            if let error = error as? AWSMobileClientError {
                print(error.localizedDescription)
            }
            if let userState = userState {
                print("Status: \(userState.rawValue)")
                
                AWSMobileClient.default().getUserAttributes { (attributes, error) in
                    if let error = error {
                        print("Error getting user attributes: \(error.localizedDescription)")
                        return
                    }

                    print(attributes)
                }

                self.getIdentityId(oldIdentityId: AWSMobileClient.default().identityId) { task in
                    if let error = task.error {
                        self.delegate?.loginResult(.failure(error))
                        print("Error: \(error.localizedDescription) \((error as NSError).userInfo)")
                    }
                    if let result = task.result {
                        UserDefaultsHelper.save(value: AWSMobileClient.default().identityId, key: .signedInIdentityId)
                        UserDefaultsHelper.setAppState(state: .loggedIn)
                        
                        self.delegate?.loginResult(.success(()))
                        print("Cognito Identity Id: \(result)")
                    }
                    
                    
                    self.updateAWSServicesCredentials()
                
                    self.attachPolicy()

                }
            }
        }
    }
    
    private func getIdentityId(oldIdentityId: String? = nil, retriesCount: Int = 1, completion: @escaping (AWSTask<NSString>)->()) {
        let maxRetries = 3
        
        AWSMobileClient.default().getIdentityId().continueWith { [weak self] task in
            let taskResult: String?
            if let result = task.result {
                taskResult = String(result)
            } else {
                taskResult = nil
            }
            
            if (taskResult == nil || taskResult == oldIdentityId) && retriesCount < maxRetries {
                self?.getIdentityId(oldIdentityId: oldIdentityId, retriesCount: retriesCount, completion: completion)
            } else {
                completion(task)
            }
            
            return nil
        }
    }
    
    func logout() {
        let isPolicyAttached = UserDefaultsHelper.get(for: Bool.self, key: .attachedPolicy) ?? false
        if isPolicyAttached {
            detachPolicy { [weak self] result in
                //we shouldn't prevent user from logout if detach policy failed. If policy has been corrupted then user won't be able to sign out.
                self?.awsLogout()
            }
        } else {
            self.awsLogout()
        }
    }
    
    private func awsLogout() {
        AWSMobileClient.default().signOut { error in
            if let error = error {
                print ("Error during signOut: \(error.localizedDescription)")
                
                self.error = error
                self.delegate?.logoutResult(error)
                
            } else {
                print ("Successful log out.")
                
                // clear the cached credentials
                AWSMobileClient.default().clearCredentials()
                AWSMobileClient.default().clearKeychain()
                print("properly cleared credentials and keychain")

                // set initial state
                UserDefaultsHelper.setAppState(state: .customAWSConnected)
                UserDefaultsHelper.removeObject(for: .signedInIdentityId)
                
                self.updateAWSServicesCredentials()
    
                self.delegate?.logoutResult(nil)
            }
        }
    }
    
    func createAWSConfiguration(with configurationModel: CustomConnectionModel) -> [String: Any] {
        let config: [String: Any] = [
            "UserAgent": "aws-amplify-cli/0.1.0",
            "Version": "0.1.0",
            "IdentityManager": [
                "Default": [:]
            ],
            "CredentialsProvider": [
                "CognitoIdentity": [
                    "Default": [
                        "PoolId": "\(configurationModel.identityPoolId)",
                        "Region": "\(configurationModel.region)"
                    ]
                ]
            ],
            "CognitoUserPool": [
                "Default": [
                    "PoolId": "\(configurationModel.userPoolId)",
                    "AppClientId": "\(configurationModel.userPoolClientId)",
                    "Region": "\(configurationModel.region)"
                ]
            ],
            "Auth": [
                "Default": [
                    "OAuth": [
                      "WebDomain": "\(configurationModel.userDomain)",
                      "AppClientId": "\(configurationModel.userPoolClientId)",
                      "SignInRedirectURI": "amazonlocationdemo://signin/",
                      "SignOutRedirectURI": "amazonlocationdemo://signout/",
                      "Scopes": [
                        "email",
                        "openid",
                        "profile"
                      ]
                    ]
                  ]
            ]
        ]
        
        return config
    }
    
    func getAWSConfigurationModel() -> CustomConnectionModel? {
        var defaultConfiguration: CustomConnectionModel? = nil
        // default configuration
        if let identityPoolId = Bundle.main.object(forInfoDictionaryKey: "IdentityPoolId") as? String {
            defaultConfiguration = CustomConnectionModel(identityPoolId: identityPoolId, userPoolClientId: "", userPoolId: "", userDomain: "", webSocketUrl: "")
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
            
        let attachPolicyRequest = AWSIoTAttachPolicyRequest()!
        attachPolicyRequest.target = AWSMobileClient.default().identityId
        attachPolicyRequest.policyName = "AmazonLocationIotPolicy"
        AWSIoT(forKey: "default").attachPolicy(attachPolicyRequest).continueWith(block: { task in
            if let error = task.error {
                print("Failed: [\(error)]")
                completion?(.failure(error))
            } else  {
                UserDefaultsHelper.save(value: true, key: .attachedPolicy)
                print("result: [\(String(describing: task.result))]")
                completion?(.success(()))
            }
            return nil
        })
    }
    
    private func detachPolicy(completion: @escaping (Result<Any, Error>)->()) {
        let attachPolicyRequest = AWSIoTDetachPolicyRequest()!
        attachPolicyRequest.target = AWSMobileClient.default().identityId
        attachPolicyRequest.policyName = "AmazonLocationIotPolicy"
        
        AWSIoT(forKey: "default").detachPolicy(attachPolicyRequest).continueWith(block: { task in
            if let error = task.error {
                print("Failed: [\(error)]")
                completion(.failure(error))
            } else  {
                UserDefaultsHelper.save(value: false, key: .attachedPolicy)
                print("result: [\(String(describing: task.result))]")
                completion(.success(task.result as Any))
            }
            return nil
        })
    }
    
    func validate(identityPoolId: String, completion: @escaping (Result<Void, Error>)->()) {
        createValidationIdentity(identityPoolId: identityPoolId)
        let identity = getValidationIdentity()
        
        let request = AWSCognitoIdentityGetIdInput()!
        request.identityPoolId = identityPoolId
        
        identity.getId(request) { response, error in
            if response != nil {
                completion(.success(()))
            } else {
                let defaultError = NSError(domain: StringConstant.login, code: -1)
                completion(.failure(error ?? defaultError))
            }
        }
    }
    
    private func createValidationIdentity(identityPoolId: String) {
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: identityPoolId.toRegionType(), identityPoolId: identityPoolId)
        
        guard let configuration = AWSServiceConfiguration(region: identityPoolId.toRegionType(), credentialsProvider: credentialProvider) else { return }
        
        AWSCognitoIdentity.register(with: configuration, forKey: Constants.awsCognitoIdentityKey)
    }
    
    private func getValidationIdentity() -> AWSCognitoIdentity {
        return AWSCognitoIdentity(forKey: Constants.awsCognitoIdentityKey)
    }
    
    func updateAWSServicesCredentials() {
        guard let configurationModel = self.getAWSConfigurationModel() else {
            print("Can't read default configuration from awsconfiguration.json")
            return
        }
        
        // Now that we have refreshed to the latest itendityId qw need to make sure
        // that AWSServiceManager promotes the latest credentials to services such as AWSLocation
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: configurationModel.identityPoolId.toRegionType(),
            identityPoolId: configurationModel.identityPoolId,
            identityProviderManager: AWSMobileClient.default()
        )
        
        let locationConfig = AWSServiceConfiguration(region: configurationModel.identityPoolId.toRegionType(), credentialsProvider: credentialsProvider)
        
        AWSLocation.register(with: locationConfig!, forKey: "default")
        AWSIoT.register(with: locationConfig!, forKey: "default")
        
        AWSServiceManager.default().defaultServiceConfiguration = locationConfig
    }
}
