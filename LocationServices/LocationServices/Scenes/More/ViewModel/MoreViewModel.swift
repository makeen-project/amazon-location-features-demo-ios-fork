//
//  MoreViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class MoreViewModel: MoreViewModelProtocol {
    private let datas: [MoreCellModel] = [MoreCellModel(type: .attribution), MoreCellModel(type: .about), MoreCellModel(type: .termsAndConditions)]
    
    func getCellItems(_ indexPath: IndexPath) -> MoreCellModel {
        return datas[indexPath.row]
    }
    
    func getItemCount() -> Int {
        datas.count
    }
}
