//
//  LoginViewModelTests.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0


import XCTest
@testable import LocationServices

final class LoginViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

// Disabling it since it is suppose to not call real api
//    func testIsSignedIn() throws {
//        let loginViewModel = LoginViewModel()
//        XCTAssertEqual(loginViewModel.isSignedIn(), false, "Expected some value in isSignedIn")
//    }
    
    func testHasLocalUser() throws {
        let customLoginModel = CustomConnectionModel(identityPoolId: "identityPoolId",
                                               userPoolClientId: "userPoolClientId",
                                               userPoolId: "userPoolId",
                                               userDomain: "userDomain",
                                               webSocketUrl: "webSocketURL"
        )
        
        UserDefaultsHelper.saveObject(value: customLoginModel, key: .awsConnect)
        let loginViewModel = LoginViewModel()
        XCTAssertEqual(loginViewModel.hasLocalUser(), true, "Expected local user")
    }
    
    func testHasNoLocalUser() throws {
        let loginViewModel = LoginViewModel()
        XCTAssertEqual(loginViewModel.hasLocalUser(), false, "Expected no local user")
    }
    
}
