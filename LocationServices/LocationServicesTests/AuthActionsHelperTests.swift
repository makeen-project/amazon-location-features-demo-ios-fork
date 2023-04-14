//
//  AuthActionsHelperTests.swift
//  AuthActionsHelperTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import XCTest
@testable import LocationServices

final class AuthActionsHelperTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTryToPerformAuthAction() throws {
        UserDefaultsHelper.setAppState(state: .loggedIn)
        let authActionsHelper = AuthActionsHelper()
        authActionsHelper.tryToPerformAuthAction {[weak self] in
            guard let self else {
                XCTAssert(false)
                return }
            XCTAssert(true, "Auth action performed successfully")
        }
       sleep(4)
    }

}
