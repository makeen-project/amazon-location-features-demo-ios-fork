//
//  AuthActionsHelper.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol AuthActionsHelperDelegate: AnyObject {
    func showLoginFlow()
    func showLoginSuccess()
}

class AuthActionsHelper {
    
    weak var delegate: AuthActionsHelperDelegate?
    
    func tryToPerformAuthAction(_ action: ()->()) {
        let authStatus = LoginViewModel.getAuthStatus()
        
        switch authStatus {
        case .defaultConfig:
            delegate?.showLoginFlow()
        case .customConfig:
            delegate?.showLoginSuccess()
        case .authorized:
            action()
        }
    }
}
