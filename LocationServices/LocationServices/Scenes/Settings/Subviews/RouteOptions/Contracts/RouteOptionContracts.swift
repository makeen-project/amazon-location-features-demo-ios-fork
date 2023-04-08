//
//  RouteOptionContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol RouteOptionViewModelProtocol: AnyObject {
    var delegate: RouteOptionViewModelOutputDelegate? { get set }
    func loadData()
    func saveTollOption(state: Bool)
    func saveFerriesOption(state: Bool)
}

protocol RouteOptionViewModelOutputDelegate: AnyObject {
    func updateViews(tollOption: Bool, ferriesOption: Bool)
}
