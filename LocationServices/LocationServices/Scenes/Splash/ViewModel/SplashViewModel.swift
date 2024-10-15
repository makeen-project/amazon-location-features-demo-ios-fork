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
        
        let isValid = try await loginService.validate(identityPoolId: customConfiguration.identityPoolId)
        
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
        guard let configurationModel = await loginService.getAWSConfigurationModel() else {
            print("Can't read default configuration from awsconfiguration.json")
            setupCompleted()
            return
        }

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
        try await CognitoAuthHelper.initialise(identityPoolId: configurationModel.identityPoolId)
        self.setupCompleted()
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
