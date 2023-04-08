//
//  PostLoginContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol PostLoginViewModelProtocol: AnyObject {
    var delegate: PostLoginViewModelOutputDelegate? { get set }
    func login()
}

protocol PostLoginViewModelOutputDelegate: AnyObject, AlertPresentable {
    func sigInCompleted()
}

protocol PostLoginViewProtocol: AnyObject {
    var delegate: PostLoginViewOutputDelegate? { get set }
}

protocol PostLoginViewOutputDelegate: AnyObject {
    func dismissAction()
    func signInAction()
}
