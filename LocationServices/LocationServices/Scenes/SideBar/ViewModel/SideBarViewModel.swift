//
//  SideBarViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class SideBarViewModel: SideBarViewModelProtocol {
    private let datas: [SideBarCellModel] = [SideBarCellModel(type: .navigate), SideBarCellModel(type: .tracking), SideBarCellModel(type: .settings), SideBarCellModel(type: .more)]
    
    func getCellItems(_ indexPath: IndexPath) -> SideBarCellModel {
        return datas[indexPath.row]
    }
    
    func getItemCount() -> Int {
        datas.count
    }
}
