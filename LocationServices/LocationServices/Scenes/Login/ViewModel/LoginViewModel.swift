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
        awsLoginService.login()
    }
    
    func logout() {
        awsLoginService.logout(skipPolicy: false)
    }
    
    func connectAWS(identityPoolId: String?, userPoolId: String?, userPoolClientId: String?, userDomain: String?, websocketUrl: String?, region: String?, apiKey: String?) {
        
        guard let identityPoolId = identityPoolId?.trimmingCharacters(in: .whitespacesAndNewlines),
              let userPoolId = userPoolId?.trimmingCharacters(in: .whitespacesAndNewlines),
              let userPoolClientId = userPoolClientId?.trimmingCharacters(in: .whitespacesAndNewlines),
              var userDomain = userDomain?.trimmingCharacters(in: .whitespacesAndNewlines),
              var webSocketUrl = websocketUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
              let region = region?.trimmingCharacters(in: .whitespacesAndNewlines),
              let apiKey = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            
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
            let isValid = try await awsLoginService.validate(identityPoolId: identityPoolId, region: "")
            if isValid {
                DispatchQueue.main.async {
                    self.saveAWS(identityPoolId: identityPoolId, userPoolId: userPoolId, userPoolClientId: userPoolClientId, userDomain: userDomain, webSocketUrl: webSocketUrl, region: region, apiKey: apiKey)
                }
            }
            else {
                
                let model = AlertModel(title: StringConstant.error, message: StringConstant.incorrectIdentityPoolIdMessage, cancelButton: nil, okButton: StringConstant.ok)
                
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
        let model = AlertModel(title: StringConstant.restartAppTitle, message: StringConstant.restartAppExplanation, cancelButton: nil, okButton: StringConstant.terminate)

        // repeat until the user is kill the app itself and restart it.
        model.okHandler = {
            // for now we are just kill the app
            exit(0)
            // for Apple release seems like we need to constantly show an alert.
            //self.delegate?.showAlert(model)
        }
        delegate?.showAlert(model)
    }
    
    func disconnectAWS() {
        // TODO: here we need to investigate if we can apply default configuration to AWSMobileService without restart of application.
        // if we signed it, make sign out first
        if isSignedIn() {
            awsLoginService.logout(skipPolicy: false)
        }
        
        delegate?.cloudConnectionDisconnected()
                
        UserDefaultsHelper.setAppState(state: .prepareDefaultAWSConnect)
        
        // remove custom configuration
        UserDefaultsHelper.removeObject(for: .awsConnect)
        
        let model = AlertModel(title: StringConstant.restartAppTitle, message: StringConstant.restartAppExplanation, cancelButton: nil, okButton: StringConstant.terminate)
        
        // repeat until the user is kill the app itself and restart it.
        model.okHandler = {
            // for now we are just kill the app
            exit(0)
            // for Apple release seems like we need to constantly show an alert.
            //self.delegate?.showAlert(model)
            
        }
        delegate?.showAlert(model)
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
        return false
        //return AWSMobileClient.default().isSignedIn
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
