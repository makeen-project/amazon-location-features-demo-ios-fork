//
//  ExplorePresentation.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

struct ExplorePresentation {
    
    var userId: String?
    var userName: String?
    var userMail: String?
    var postalCode: String?
    var userInitial: String?
    
    init(model: AWSUserModel) {
        self.userId = model.userId
        self.userName = model.name
        self.userMail = model.email
        self.userInitial = model.name?.createInitial()
        self.postalCode = model.postalCode
    }
}
