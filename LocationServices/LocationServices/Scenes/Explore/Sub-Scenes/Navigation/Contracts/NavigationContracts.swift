//
//  NavigationContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol NavigationViewModelProtocol: AnyObject {
    var delegate: NavigationViewModelOutputDelegate? { get set }
    func loadNavigationDetails()
}

protocol NavigationViewModelOutputDelegate: AnyObject {
    func updateResults()
}
