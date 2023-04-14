//
//  SplashViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class SplashViewModel: SplashViewModelProtocol {
    
    var setupCompleteHandler: VoidHandler?
    private let loginService: AWSLoginService
    
    init(loginService: AWSLoginService) {
        self.loginService = loginService
    }
    
    func setupAWS() {
        setupCompleteHandler?()
    }
}
