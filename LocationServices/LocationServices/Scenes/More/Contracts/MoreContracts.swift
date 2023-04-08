//
//  MoreContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol MoreViewModelProtocol: AnyObject {
    func getCellItems(_ indexPath: IndexPath) -> MoreCellModel
    func getItemCount() -> Int
}

protocol MoreNavigationDelegate: AnyObject {
    func showNextScene(type: MoreCellType)
}
