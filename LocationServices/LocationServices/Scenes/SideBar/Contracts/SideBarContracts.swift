//
//  SideBarContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol SideBarViewModelProtocol: AnyObject {
    func getCellItems(_ indexPath: IndexPath) -> SideBarCellModel
    func getItemCount() -> Int
}

protocol SideBarDelegate: AnyObject {
    func showNextScene(type: SideBarCellType)
}
