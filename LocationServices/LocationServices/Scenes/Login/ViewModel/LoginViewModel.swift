//
//  LoginViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

enum AuthStatus {
    case defaultConfig
    case customConfig
    case authorized
}

final class LoginViewModel: LoginViewModelProtocol {
    var delegate: LoginViewModelOutputDelegate?
    
    var awsLoginService: AWSLoginServiceProtocol! {
        didSet {
            awsLoginService.delegate = self
        }
    }
    
    static func getAuthStatus() -> AuthStatus {
        if UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) != nil {
            if UserDefaultsHelper.getAppState() == .loggedIn {
                return .authorized
            } else {
                return .customConfig
            }
        } else {
            return .defaultConfig
        }
    }

    func login() {
        Task {
            try await awsLoginService.login()
        }
    }
    
    func logout() {
        awsLoginService.logout(skipPolicy: false)
    }
    
    func connectAWS(identityPoolId: String?, userPoolId: String?, userPoolClientId: String?, userDomain: String?, websocketUrl: String?) {
        
        guard let identityPoolId = identityPoolId?.trimmingCharacters(in: .whitespacesAndNewlines),
              let userPoolId = userPoolId?.trimmingCharacters(in: .whitespacesAndNewlines),
              let userPoolClientId = userPoolClientId?.trimmingCharacters(in: .whitespacesAndNewlines),
              var userDomain = userDomain?.trimmingCharacters(in: .whitespacesAndNewlines),
              var webSocketUrl = websocketUrl?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            
            let model = AlertModel(title: StringConstant.error, message: StringConstant.notAllFieldsAreConfigured, okButton: StringConstant.ok)
            delegate?.showAlert(model)
            return
        }
        
        // check if we have https:// or http:// - just eliminate it
        ["https://", "http://"].forEach {
            userDomain = userDomain.replacingOccurrences(of: $0, with: "")
        }
        ["https://", "http://"].forEach {
            webSocketUrl = webSocketUrl.replacingOccurrences(of: $0, with: "")
        }
        Task {   
            do {
                let isValid = try await awsLoginService.validate(identityPoolId: identityPoolId)
                if isValid {
                    DispatchQueue.main.async {
                        self.saveAWS(identityPoolId: identityPoolId, userPoolId: userPoolId, userPoolClientId: userPoolClientId, userDomain: userDomain, webSocketUrl: webSocketUrl, region: "", apiKey: "")
                    }
                }
                else {
                    
                    let model = AlertModel(title: StringConstant.error, message: StringConstant.incorrectIdentityPoolIdMessage, cancelButton: nil, okButton: StringConstant.ok)
                    DispatchQueue.main.async {
                        self.delegate?.showAlert(model)
                    }
                }
            }
            catch {
                let model = AlertModel(title: StringConstant.error, message: "\(StringConstant.incorrectIdentityPoolIdMessage). \(error.localizedDescription)", cancelButton: nil, okButton: StringConstant.ok)
                DispatchQueue.main.async {
                    self.delegate?.showAlert(model)
                }
            }
        }
    }
    
    private func saveAWS(identityPoolId: String, userPoolId: String, userPoolClientId: String, userDomain: String, webSocketUrl: String, region: String, apiKey: String) {
        saveDatatoDefaults(identityPoolId: identityPoolId,
                           userPoolId: userPoolId,
                           userPoolClientId: userPoolClientId,
                           userDomain: userDomain,
                           webSocketURL: webSocketUrl,
                           region: region,
                           apiKey: apiKey)
        
        delegate?.identityPoolIdValidationSucceed()
    }
    
    func disconnectAWS() {
        awsLoginService.disconnectAWS()
        delegate?.cloudConnectionDisconnected()
    }
    
    private func saveDatatoDefaults(identityPoolId: String,
                                    userPoolId: String,
                                    userPoolClientId: String,
                                    userDomain: String,
                                    webSocketURL: String,
                                    region: String,
                                    apiKey: String) {
        let customLoginModel = CustomConnectionModel(identityPoolId: identityPoolId,
                                               userPoolClientId: userPoolClientId,
                                               userPoolId: userPoolId,
                                               userDomain: userDomain,
                                               webSocketUrl: webSocketURL,
                                               apiKey: apiKey,
                                               region: region
        )
        
        UserDefaultsHelper.saveObject(value: customLoginModel, key: .awsConnect)
        UserDefaultsHelper.save(value: true, key: .showSignInOnAppStart)
    }
    
    func hasLocalUser() -> Bool {
        return UserDefaultsHelper.getObject(value: CustomConnectionModel.self, key: .awsConnect) != nil
    }
    
    func isSignedIn() -> Bool {
        return UserDefaultsHelper.getAppState() == .loggedIn
    }
}

extension LoginViewModel: AWSLoginServiceOutputProtocol {
    func loginResult(_ result: Result<Void, Error>) {
        delegate?.loginCompleted()
    }
    
    func logoutResult(_ error: Error?) {
        delegate?.logoutCompleted()
        print("Logout Successfully")
    }
}
