//
//  SplashViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class SplashViewModel: SplashViewModelProtocol {
    
    var setupCompleteHandler: VoidHandler?
    private var observeLogoutResult: Bool = true
    
    weak var delegate: SplashViewModelDelegate?
    
    func setupDefaults() {
        UserDefaultsHelper.removeObject(for: .navigationRoute)
        UserDefaultsHelper.removeObject(for: .isNavigationMode)
        UserDefaultsHelper.removeObject(for: .isTrackingActive)
    }
    
    func setupAWS() {
        Task {
            try await setupAWSConfiguration()
        }
    }
    
    func setupAWSConfiguration() async throws {
        if let regions = (Bundle.main.object(forInfoDictionaryKey: "AWSRegions") as? String)?.components(separatedBy: ",") {
            AWSRegionSelector.shared.setFastestAWSRegion(apiRegions: regions) { [self]_ in 
                Task {
                    try await setupValidAWSConfiguration()
                }
            }
        }
    }
    
    private func setupValidAWSConfiguration() async throws {
        guard let configurationModel = GeneralHelper.getAWSConfigurationModel() else {
            print("Can't read default configuration from awsconfiguration.json")
            setupCompleted()
            return
        }
        try await initializeMobileClient(configurationModel: configurationModel)
    }
    
    private func initializeMobileClient(configurationModel: CustomConnectionModel) async throws {
        try await CognitoAuthHelper.initialise(identityPoolId: configurationModel.identityPoolId)
        try await ApiAuthHelper.initialise(apiKey: configurationModel.apiKey, region: configurationModel.region)
        self.setupCompleted()
    }
    
    private func setupCompleted() {
        DispatchQueue.main.async {
            self.setupCompleteHandler?()
        }
    }
}
