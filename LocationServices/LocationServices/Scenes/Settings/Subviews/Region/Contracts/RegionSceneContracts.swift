//
//  RegionSceneContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

protocol RegionSceneViewModelProcotol: AnyObject {
    var delegate: RegionSceneViewModelOutputDelegate? { get set }
    func loadCurrentData()
    func getItemCount() -> Int
    func getItemFor(_ indexPath: IndexPath) -> CommonSelectableCellModel
    func saveSelectedState(_ indexPath: IndexPath)
}

protocol RegionSceneViewModelOutputDelegate: AnyObject {
    func updateTableView(index: Int)
}
