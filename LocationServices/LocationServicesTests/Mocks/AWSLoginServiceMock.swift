//
//  LoginServiceMock.swift
//  LocationServicesTests
//
//  Created by Zeeshan Sheikh on 27/09/2023.
//

import Foundation
@testable import LocationServices

class AWSLoginSericeMock : AWSLoginServiceProtocol {
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
    
    func validate(identityPoolId: String, completion: @escaping (Result<Void, Error>) -> ()) {
        perform { [weak self] in
            guard let result = self?.validateResult else { return }
            completion(result)
        }
    }
    
    private func perform(action: @escaping ()->()) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            action()
        }
    }
}

class AWSLoginServiceOutputProtocolMock : AWSLoginServiceOutputProtocol {
    
}
