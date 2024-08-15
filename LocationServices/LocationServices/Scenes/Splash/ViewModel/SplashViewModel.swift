//
//  SplashViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class SplashViewModel: SplashViewModelProtocol, AWSLoginServiceOutputProtocol {
    
    var setupCompleteHandler: VoidHandler?
    private let loginService: AWSLoginService
    private var observeLogoutResult: Bool = true
    
    weak var delegate: SplashViewModelDelegate?
    
    init(loginService: AWSLoginService) {
        self.loginService = loginService
        
        loginService.delegate = self
    }
    
    func setupAWS() {
        Task {
            try await setupAWSConfiguration()
        }
    }
    
    func setupAWSConfiguration() async throws {
        let customConfiguration = UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect)
        guard let customConfiguration else {
            try await setupValidAWSConfiguration()
            return
        }
        
        let isValid = try await loginService.validate(identityPoolId: customConfiguration.identityPoolId, region: customConfiguration.region)
        
        if !isValid {
                UserDefaultsHelper.setAppState(state: .prepareDefaultAWSConnect)
                // remove custom configuration
                UserDefaultsHelper.removeObject(for: .awsConnect)
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.wasResetToDefaultConfig, object: self)
                }
        }
        
        try await self.setupValidAWSConfiguration()
    }
    
    private func setupValidAWSConfiguration() async throws {
        guard let configurationModel = loginService.getAWSConfigurationModel() else {
            print("Can't read default configuration from awsconfiguration.json")
            setupCompleted()
            return
        }
        
        //let config = loginService.createAWSConfiguration(with: configurationModel)
        
        //AWSInfo.configureDefaultAWSInfo(config)
        
        // Here we connected and should set appropriate flags for it
        // possible connection states:
        // awsConnected - we are connected to default AWS configuration.
        // awsCustomConnected - we are connected to custom AWS configuration.
        
        if let isCustomConnection = UserDefaultsHelper.get(for: Bool.self, key: .awsCustomConnect), isCustomConnection == true {
            UserDefaultsHelper.save(value: true, key: .awsCustomConnected)
            UserDefaultsHelper.removeObject(for: .awsCustomConnect)
        }
        
        try await initializeMobileClient(configurationModel: configurationModel)
    }
    
    private func initializeMobileClient(configurationModel: CustomConnectionModel) async throws {
        UserDefaultsHelper.save(value: "", key: .userInitial)
                            print("Logged Out")
                            self.validateIdentityId()
        ApiAuthHelper.initialize(apiKey: configurationModel.apiKey, region:  configurationModel.region)
        try await CognitoAuthHelper.initialize(identityPoolId: configurationModel.identityPoolId)

//        AWSMobileClient.default().initialize { [weak self] (userState, error) in
//            // Calling getIdentityId in order to force refresh the AWSMobileClient identityId to the latest one
//            self?.addListener()
//            print("AWS login?: \(AWSMobileClient.default().isSignedIn)")
//            
//            if let userState = userState {
//                switch userState {
//                case .signedIn:
//                    print("Logged In")
//                    AWSMobileClient.default().getTokens { [weak self] tokens, error in
//                        self?.observeLogoutResult = true
//                        self?.validateIdentityId()
//                    }
//                default:
//                    UserDefaultsHelper.save(value: "", key: .userInitial)
//                    print("Logged Out")
//                    self?.validateIdentityId()
//                }
//            } else if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//        }
    }
    
    private func addListener() {
//        AWSMobileClient.default().addUserStateListener(self) { [weak self] (userState, info) in
//            switch (userState) {
//            case .guest:
//                print("user is in guest mode.")
//            case .signedOut:
//                print("user signed out")
//            case .signedIn:
//                print("user is signed in.")
//            case .signedOutUserPoolsTokenInvalid:
//                print("need to login again.")
//                self?.observeLogoutResult = false
//                self?.validateIdentityId()
//            case .signedOutFederatedTokensInvalid:
//                print("user logged in via federation, but currently needs new tokens")
//                self?.observeLogoutResult = false
//                self?.validateIdentityId()
//            default:
//                print("unsupported")
//            }
//        }
    }
    
    private func validateIdentityId() {
//        AWSMobileClient.default().getIdentityId().continueWith { [weak self] task in
//            
//            self?.loginService.updateAWSServicesCredentials()
//            
//            // here we are actually connect to Amazon location
//            // it can be either custom or default
//            let state = UserDefaultsHelper.getAppState()
//            
//            if state != .loggedIn {
//                if UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) != nil {
//                    UserDefaultsHelper.setAppState(state: .customAWSConnected)
//                } else {
//                    UserDefaultsHelper.setAppState(state: .defaultAWSConnected)
//                }
//            }
//            
//            if state == .loggedIn {
//                self?.loginService.attachPolicy { [weak self] _ in
//                    self?.validateStoredIdentityId()
//                }
//            } else {
//                self?.validateStoredIdentityId()
//            }
//            
//            return nil
//        }
        
        self.setupCompleted()
    }
    
    private func validateStoredIdentityId() {
//        guard AWSMobileClient.default().isSignedIn,
//              let currentIdentityId = AWSMobileClient.default().identityId,
//              let actualId = UserDefaultsHelper.get(for: String.self, key: .signedInIdentityId),
//              currentIdentityId != actualId else {
//
//            self.setupCompleted()
//            return
//        }
//        
//        //the identityId is different from the one that is represent the current signed in user
//        //in this case we make a sign out as new identityId doesn't have permissions for geofence and tracking
//        let alertModel = AlertModel(title: StringConstant.warning, message: StringConstant.sessionExpiredError, cancelButton: nil) { [weak self] in
//            self?.loginService.logout(skipPolicy: true)
//        }
//        DispatchQueue.main.async {
//            self.delegate?.showAlert(alertModel)
//        }
    }
    
    private func setupCompleted() {
        DispatchQueue.main.async {
            self.setupCompleteHandler?()
        }
    }
    
    // MARK: - AWSLoginServiceOutputProtocol
    func logoutResult(_ error: Error?) {
        guard observeLogoutResult else { return }
        setupCompleted()
    }
}
