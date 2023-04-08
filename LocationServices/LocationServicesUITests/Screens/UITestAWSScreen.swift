//
//  UITestAWSScreen.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest

private final class UITestBundle {}

struct UITestAWSScreen: UITestScreen {
    let app: XCUIApplication
    
    private enum Identifiers {
        static var idpTextField: String { ViewsIdentifiers.AWSConnect.identityPoolTextField }
        static var domainTextField: String { ViewsIdentifiers.AWSConnect.userDomainTextField }
        static var clientIDTextField: String { ViewsIdentifiers.AWSConnect.userPoolClientTextField }
        static var poolIDTextField: String { ViewsIdentifiers.AWSConnect.userPoolTextField }
        static var webSocketTextField: String { ViewsIdentifiers.AWSConnect.webSocketURLTitleTextField }
        
        static var connectButton: String { ViewsIdentifiers.AWSConnect.connectButton }
        static var disconnectButton: String { ViewsIdentifiers.AWSConnect.disconnectButton }
        static var signInButton: String { ViewsIdentifiers.AWSConnect.signInButton }
        static var signOutButton: String { ViewsIdentifiers.AWSConnect.signOutButton }
    }
    
    enum Constants {
        static let springboardIdentifier = "com.apple.springboard"
        static let continueSignIn = "Continue"
        static let userNameTextField = "Username"
        static let passwordTextField = "Password"
        static let signInSubmitButton = "Submit"
        
        static var identityPoolId: String {
            return Bundle(for: UITestBundle.self).object(forInfoDictionaryKey: "TestIdentityPoolId") as! String
        }
        
        static var userPoolClientId: String {
            Bundle(for: UITestBundle.self).object(forInfoDictionaryKey: "TestUserPoolClientId") as! String
        }
        
        static var userPoolId: String {
            Bundle(for: UITestBundle.self).object(forInfoDictionaryKey: "TestUserPoolId") as! String
        }
        
        static var userDomain: String {
            Bundle(for: UITestBundle.self).object(forInfoDictionaryKey: "TestUserDomain") as! String
        }
        
        static var webSocketUrl: String {
            Bundle(for: UITestBundle.self).object(forInfoDictionaryKey: "TestWebSocketUrl") as! String
        }
        
        static var sampleUserName: String {
            Bundle(for: UITestBundle.self).object(forInfoDictionaryKey: "TestSampleUserName") as! String
        }
        
        static var samplePassword: String {
            Bundle(for: UITestBundle.self).object(forInfoDictionaryKey: "TestSamplePassword") as! String
        }
    }
    
    func connectAWSConnect() -> Self {
        return typeAWSConnectAccount(identityPoolId: Constants.identityPoolId, userPoolClientId: Constants.userPoolClientId, userPoolId: Constants.userPoolId, userDomain: Constants.userDomain, webSocketUrl: Constants.webSocketUrl)
        .tapConnectButton()
        .waitForAWSConnectResponse()
    }
    
    func typeAWSConnectAccount(identityPoolId: String, userPoolClientId: String, userPoolId: String, userDomain: String, webSocketUrl: String) -> Self {
        selectTextField(identifier: Identifiers.idpTextField).typeText(identityPoolId)
        selectTextField(identifier: Identifiers.domainTextField).typeText(userDomain)
        selectTextField(identifier: Identifiers.clientIDTextField).typeText(userPoolClientId)
        selectTextField(identifier: Identifiers.poolIDTextField).typeText(userPoolId)
        selectTextField(identifier: Identifiers.webSocketTextField).typeText(webSocketUrl)
        return self
    }
    
    func tapConnectButton() -> Self {
      let connectButton = app.buttons.matching(identifier: Identifiers.connectButton).element
        XCTAssertTrue(connectButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        connectButton.tap()
        return self
    }
    
    func tapDisconnectButton() -> Self {
      let disconnectButton = app.buttons.matching(identifier: Identifiers.disconnectButton).element
        XCTAssertTrue(disconnectButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        disconnectButton.tap()
        return self
    }
    
    func waitForAWSConnectResponse() -> Self {
        let alert = app.alerts.element
        XCTAssertTrue(alert.waitForExistence(timeout: UITestWaitTime.request.time))
        let responseMessage = alert.label
        XCTAssertEqual(responseMessage, StringConstant.restartAppTitle)
        alert.buttons.firstMatch.tap()
        return self
    }
    
    func waitForSignoutButton() -> Self {
        let signOutButton = app.buttons.matching(identifier: Identifiers.signOutButton).element
        XCTAssertTrue(signOutButton.waitForExistence(timeout: UITestWaitTime.request.time))
        
        return self
    }
    func signInAWSAccount() -> Self {
        return tapSignInButton()
        .tapContinueSignInButton()
        .typeAWSSignInAccount()
        .waitForSignoutButton()
    }
    
    func tapSignInButton(timeout: Double = UITestWaitTime.regular.time) -> Self {
        let signInButton = app.buttons.matching(identifier: Identifiers.signInButton).element
        XCTAssertTrue(signInButton.waitForExistence(timeout: timeout))
        signInButton.tap()
        
        return self
    }
    
    func tapSignOutButton() -> Self {
        let signOutButton = app.buttons.matching(identifier: Identifiers.signOutButton).element
        XCTAssertTrue(signOutButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        signOutButton.tap()
        
        return self
    }
    
    func tapContinueSignInButton() -> Self {
        let springboard = XCUIApplication(bundleIdentifier: Constants.springboardIdentifier)
        let continueButton = springboard.buttons[Constants.continueSignIn]
        XCTAssertTrue(continueButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        continueButton.tap()
        
        return self
    }
    
    func typeAWSSignInAccount(required: Bool = false) -> Self {
        let webview = app.webViews.element
        let doesWebViewExist = webview.waitForExistence(timeout: UITestWaitTime.regular.time)
        if required {
            XCTAssertTrue(doesWebViewExist)
        } else if !doesWebViewExist {
            return signOutSignIn()
        }
        
        let userNameTextField = webview.textFields[Constants.userNameTextField]
        let doesUserNameTextFieldExist = userNameTextField.waitForExistence(timeout: UITestWaitTime.request.time)
        if required {
            XCTAssertTrue(doesUserNameTextFieldExist)
        } else if !doesUserNameTextFieldExist {
            return signOutSignIn()
        }
        
        userNameTextField.tap()
        userNameTextField.typeText(Constants.sampleUserName)
        
        let passwordTextField = webview.secureTextFields[Constants.passwordTextField]
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: UITestWaitTime.regular.time))
        passwordTextField.tap()
        passwordTextField.typeText(Constants.samplePassword)
        
        let signInButton = webview.buttons.firstMatch
        XCTAssertTrue(signInButton.waitForExistence(timeout: UITestWaitTime.regular.time))
        signInButton.tap()
        
        return self
    }
    
    private func signOutSignIn() -> Self {
        return tapSignOutButton()
            .tapContinueSignInButton()
            .tapSignInButton(timeout: UITestWaitTime.request.time)
            .tapContinueSignInButton()
            .typeAWSSignInAccount(required: true)
    }
    
    // MARK: - Private
    private func selectTextField(identifier: String) -> XCUIElement {
        let textField = app.textFields[identifier]
        XCTAssertTrue(textField.waitForExistence(timeout: UITestWaitTime.regular.time))
        textField.tap()
        return textField
    }
}
