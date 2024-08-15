//
//  LoginViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0


import XCTest
@testable import LocationServices

final class LoginViewModelTests: XCTestCase {
    var viewModel: LoginViewModel!
    var loginService: AWSLoginSericeMock!
    var delegate: LoginViewModelOutputDelegateMock!
    enum Constants {
        static let waitRequestDuration: TimeInterval = 10
        static let apiRequestDuration: TimeInterval = 1
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = LoginViewModel()
        delegate = LoginViewModelOutputDelegateMock()
        viewModel.delegate = delegate
        loginService = AWSLoginSericeMock(delay: Constants.apiRequestDuration)
        viewModel.awsLoginService = loginService
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testHasLocalUser() throws {
        let customLoginModel = CustomConnectionModel(identityPoolId: "identityPoolId",
                                               userPoolClientId: "userPoolClientId",
                                               userPoolId: "userPoolId",
                                               userDomain: "userDomain",
                                                     webSocketUrl: "webSocketURL", apiKey: "apiKey"
        )
        
        UserDefaultsHelper.saveObject(value: customLoginModel, key: .awsConnect)
        XCTAssertEqual(viewModel.hasLocalUser(), true, "Expected local user")
    }
    
    func testHasNoLocalUser() throws {
        XCTAssertEqual(viewModel.hasLocalUser(), false, "Expected no local user")
    }
    
    func testGetAuthStatus() throws {
        XCTAssertEqual(LoginViewModel.getAuthStatus(), .defaultConfig, "Expected default config")
    }
    
    func testConnectAWS() throws {
        loginService.validateResult = .success(())
        viewModel.connectAWS(identityPoolId: "a", userPoolId: "s", userPoolClientId: "d", userDomain: "https://e", websocketUrl: "https://f")
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasIdentityPoolIdValidationSucceed ?? false
 
        }, timeout: Constants.waitRequestDuration, message: "Expected hasIdentityPoolIdValidationSucceed true")
    }
    
    func testDisconnectAWS() throws {
        viewModel.disconnectAWS()
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasShownAlert ?? false
 
        }, timeout: Constants.waitRequestDuration, message: "Expected shownAlert on disconnectAWS true")
    }
    
    func testLogin() throws {
        loginService.loginResult = .success(())
        viewModel.login()
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasLoginCompleted ?? false

        }, timeout: Constants.waitRequestDuration, message: "Expected hasLoginCompleted on login true")
    }
    
    func testLogout() throws {
        loginService.logoutResult = .success(())
        viewModel.logout()
        XCTWaiter().wait(until: { [weak self] in
            return self?.delegate.hasLogoutCompleted ?? false

        }, timeout: Constants.waitRequestDuration, message: "Expected hasLoginCompleted on login true")
    }
}

class LoginViewModelOutputDelegateMock: LoginViewModelOutputDelegate {
    
    var hasCloudConnectionCompleted = false
    var hasCloudConnectionDisconnected = false
    var hasLoginCompleted = false
    var hasLogoutCompleted = false
    var hasIdentityPoolIdValidationSucceed = false
    var hasShownAlert = false
    
    func cloudConnectionCompleted() {
        hasCloudConnectionCompleted = true
    }
    
    func cloudConnectionDisconnected() {
        hasCloudConnectionDisconnected = true
    }
    
    func loginCompleted() {
        hasLoginCompleted = true
    }
    
    func logoutCompleted() {
        hasLogoutCompleted = true
    }
    
    func identityPoolIdValidationSucceed() {
        hasIdentityPoolIdValidationSucceed = true
    }
    
    func showAlert(_ model: LocationServices.AlertModel) {
        hasShownAlert = true
    }
}
