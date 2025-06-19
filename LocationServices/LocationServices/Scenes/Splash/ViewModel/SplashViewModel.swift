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
        if let regions = AWSRegionSelector.shared.getBundleRegions() {
            AWSRegionSelector.shared.setFastestAWSRegion(apiRegions: regions) { [self]_ in
                Task {
                    try await GeneralHelper.setupValidAWSConfiguration()
                    self.setupCompleted()
                }
            }
        }
    }
    
    private func setupCompleted() {
        DispatchQueue.main.async {
            self.setupCompleteHandler?()
        }
    }
}
