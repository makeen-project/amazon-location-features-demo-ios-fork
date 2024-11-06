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
        Task {   
            do {
                guard let identityPoolId = identityPoolId?.trimmingCharacters(in: .whitespacesAndNewlines),
                      let userPoolId = userPoolId?.trimmingCharacters(in: .whitespacesAndNewlines),
                      let userPoolClientId = userPoolClientId?.trimmingCharacters(in: .whitespacesAndNewlines),
                      let userDomain = userDomain?.trimmingCharacters(in: .whitespacesAndNewlines),
                      let webSocketUrl = websocketUrl?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                    DispatchQueue.main.async {
                        let model = AlertModel(title: StringConstant.error, message: StringConstant.notAllFieldsAreConfigured, okButton: StringConstant.ok)
                        self.delegate?.showAlert(model)
                    }
                    return
                }

                let isValid = try await awsLoginService.validate(identityPoolId: identityPoolId)
                if isValid {
                    let configurationModel = awsLoginService.getAWSConfigurationModel()
                    DispatchQueue.main.async {
                        var userDomainValid = userDomain
                        var webSocketUrlValid = webSocketUrl
                        // check if we have https:// or http:// - just eliminate it
                        ["https://", "http://"].forEach {
                            userDomainValid = userDomainValid.replacingOccurrences(of: $0, with: "")
                        }
                        ["https://", "http://"].forEach {
                            webSocketUrlValid = webSocketUrlValid.replacingOccurrences(of: $0, with: "")
                        }
                        
                        self.saveAWS(identityPoolId: identityPoolId, userPoolId: userPoolId, userPoolClientId: userPoolClientId, userDomain: userDomainValid, webSocketUrl: webSocketUrlValid, region: configurationModel?.region ?? "", apiKey: configurationModel?.apiKey ?? "")
                    }
                }
                else {
                    DispatchQueue.main.async {
                        let model = AlertModel(title: StringConstant.error, message: StringConstant.incorrectIdentityPoolIdMessage, cancelButton: nil, okButton: StringConstant.ok)
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
        switch result {
        case .success():
            print("Logged in")
            delegate?.loginCompleted()
        case .failure(let error):
            print("Logged in failure \(error)")
            delegate?.loginCancelled()
        }
    }
    
    func logoutResult(_ error: Error?) {
        delegate?.logoutCompleted()
        print("Logout Successfully")
    }
}
