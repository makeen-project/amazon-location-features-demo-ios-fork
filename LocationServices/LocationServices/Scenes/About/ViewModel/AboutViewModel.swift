//
//  AboutViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class AboutViewModel: AboutViewModelProtocol {
    private let datas: [AboutCellModel] = [AboutCellModel(type: .attribution), AboutCellModel(type: .version), AboutCellModel(type: .termsAndConditions), AboutCellModel(type: .help)]
    
    func getCellItems(_ indexPath: IndexPath) -> AboutCellModel {
        return datas[indexPath.row]
    }
    
    func getItemCount() -> Int {
        datas.count
    }
}
