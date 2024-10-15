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
                //            let presentation = ExplorePresentation(model: user)
                //            UserDefaultsHelper.save(value: presentation.userInitial, key: .userInitial)
                //            let userInfo = ["loginInfo": presentation.userInitial]
                //            NotificationCenter.default.post(name: Notification.updateSearchTextBarIcon, object: nil, userInfo: userInfo)
            case .failure(let error):
                let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                self.delegate?.showAlert(model)
            }
        }
    }
}

