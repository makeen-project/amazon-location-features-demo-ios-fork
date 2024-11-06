//
//  LoginServiceMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
@testable import LocationServices

class AWSLoginServiceMock : AWSLoginServiceProtocol {
    func getAWSConfigurationModel() -> LocationServices.CustomConnectionModel? {
        return CustomConnectionModel(identityPoolId: "mockidentityPoolId", userPoolClientId: "mockuserPoolClientId", userPoolId: "mockuserPoolId", userDomain: "mockuserDomain", webSocketUrl: "mockwebSocketUrl", apiKey: "mockapiKey", region: "mockregion")
    }
    
    func disconnectAWS() {
    }
    
    var delegate: LocationServices.AWSLoginServiceOutputProtocol?
    
    var validateResult: Result<Void, Error>?
    var loginResult: Result<Void, Error>?
    var logoutResult: Result<Void, Error>?
    
    let delay: TimeInterval
    
    init(delay: TimeInterval) {
        self.delay = delay
    }
    
    func login() {
        delegate?.loginResult(.success(()))
    }
    
    func logout(skipPolicy: Bool = false) {
        delegate?.logoutResult(nil)
    }
    
    func validate(identityPoolId: String) async throws -> Bool {
        return true
    }
}

class AWSLoginServiceOutputProtocolMock : AWSLoginServiceOutputProtocol {
    
}
