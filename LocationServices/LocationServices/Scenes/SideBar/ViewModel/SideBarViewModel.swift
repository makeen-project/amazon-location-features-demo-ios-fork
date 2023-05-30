//
//  SideBarViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class SideBarViewModel: SideBarViewModelProtocol {
    private let datas: [SideBarCellModel] = [SideBarCellModel(type: .explore), SideBarCellModel(type: .tracking), SideBarCellModel(type: .geofence), SideBarCellModel(type: .settings), SideBarCellModel(type: .about)]
    
    func getCellItems(_ indexPath: IndexPath) -> SideBarCellModel {
        return datas[indexPath.row]
    }
    
    func getItemCount() -> Int {
        datas.count
    }
}
