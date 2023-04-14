//
//  SplashViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import AWSMobileClientXCF

final class SplashViewModel: SplashViewModelProtocol {
    
    var setupCompleteHandler: VoidHandler?
    private let loginService: AWSLoginService
    
    init(loginService: AWSLoginService) {
        self.loginService = loginService
    }
    
    func setupAWS() {
        setupAWSConfiguration()
    }
    
    func setupAWSConfiguration() {
        let customConfiguration = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect)
        guard let customConfiguration else {
            setupValidAWSConfiguration()
            return
        }
        
        loginService.validate(identityPoolId: customConfiguration.identityPoolId) { [weak self] result in
            switch result {
            case .failure:
                // clear the cached credentials
                AWSMobileClient.default().clearCredentials()
                AWSMobileClient.default().clearKeychain()
                
                UserDefaultsHelper.setAppState(state: .prepareDefaultAWSConnect)
                // remove custom configuration
                UserDefaultsHelper.removeObject(for: .awsConnect)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.wasResetToDefaultConfig, object: self)
                }
            default:
                break
            }
            self?.setupValidAWSConfiguration()
        }
    }
    
    private func setupValidAWSConfiguration() {
        guard let configurationModel = loginService.getAWSConfigurationModel() else {
            print("Can't read default configuration from awsconfiguration.json")
            setupCompleted()
            return
        }
        
        let config = loginService.createAWSConfiguration(with: configurationModel)
        
        AWSInfo.configureDefaultAWSInfo(config)
        
        // Here we connected and should set appropriate flags for it
        // possible connection states:
        // awsConnected - we are connected to default AWS configuration.
        // awsCustomConnected - we are connected to custom AWS configuration.
        
        if let isCustomConnection = UserDefaultsHelper.get(for: Bool.self, key: .awsCustomConnect), isCustomConnection == true {
            UserDefaultsHelper.save(value: true, key: .awsCustomConnected)
            UserDefaultsHelper.removeObject(for: .awsCustomConnect)
        }
        
        initializeMobileClient()
    }
    
    private func initializeMobileClient() {
        
        AWSMobileClient.default().initialize { [weak self] (userState, error) in
            // Calling getIdentityId in order to force refresh the AWSMobileClient identityId to the latest one
            
            print("AWS login?: \(AWSMobileClient.default().isSignedIn)")
            
            AWSMobileClient.default().getIdentityId().continueWith { [weak self] task in
                
                self?.loginService.updateAWSServicesCredentials()
                
                // here we are actually connect to Amazon location
                // it can be either custom or default
                let state = UserDefaultsHelper.getAppState()
                
                if state != .loggedIn {
                    if UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) != nil {
                        UserDefaultsHelper.setAppState(state: .customAWSConnected)
                    } else {
                        UserDefaultsHelper.setAppState(state: .defaultAWSConnected)
                    }
                }
                
                if state == .loggedIn {
                    self?.loginService.attachPolicy { [weak self] _ in
                        self?.setupCompleted()
                    }
                } else {
                    self?.setupCompleted()
                }
                
                return nil
            }
            
            if let userState = userState {
                switch userState {
                case .signedIn:
                    print("Logged In")
                case .signedOut:
                    UserDefaultsHelper.save(value: "", key: .userInitial)
                    print("Logged Out")
                case .signedOutUserPoolsTokenInvalid:
                    UserDefaultsHelper.save(value: "", key: .userInitial)
                    print("User Pools refresh token is invalid or expired.")
                case .signedOutFederatedTokensInvalid:
                    UserDefaultsHelper.save(value: "", key: .userInitial)
                    print("Federated refresh token is invalid or expired.")
                default:
                    AWSMobileClient.default().signOut()
                }
            } else if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    private func setupCompleted() {
        DispatchQueue.main.async {
            self.setupCompleteHandler?()
        }
    }
}
