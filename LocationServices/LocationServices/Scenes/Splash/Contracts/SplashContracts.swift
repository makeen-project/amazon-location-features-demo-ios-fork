//
//  SplashContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol SplashViewModelProtocol: AnyObject {
    var delegate: SplashViewModelDelegate? { get set }
    var setupCompleteHandler: VoidHandler? { get set }
    func setupAWS()
}

protocol SplashViewModelDelegate: AnyObject, AlertPresentable {
}
