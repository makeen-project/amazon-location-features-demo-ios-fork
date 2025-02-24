//
//  PostLoginViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class PostLoginViewModel: PostLoginViewModelProtocol {
    
    private let awsLoginService: AWSLoginService
    
    init(awsLoginService: AWSLoginService) {
        self.awsLoginService = awsLoginService
        
        awsLoginService.delegate = self
    }
    
    var delegate: PostLoginViewModelOutputDelegate?
        
    func login() {
        Task {
            try await awsLoginService.login()
        }
    }
}

extension PostLoginViewModel: AWSLoginServiceOutputProtocol {
  
    func loginResult(_ result: Result<Void, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success:
                self.delegate?.sigInCompleted()
            case .failure(let error):
                print("Logged in failure \(error)")
            }
        }
    }
}

