//
//  AboutContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol AboutViewModelProtocol: AnyObject {
    func getCellItems(_ indexPath: IndexPath) -> AboutCellModel
    func getItemCount() -> Int
}

protocol AboutNavigationDelegate: AnyObject {
    func showNextScene(type: AboutCellType)
}
