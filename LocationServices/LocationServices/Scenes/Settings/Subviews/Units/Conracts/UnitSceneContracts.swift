//
//  UnitSceneContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

protocol UnitSceneViewModelProcotol: AnyObject {
    var delegate: UnitSceneViewModelOutputDelegate? { get set }
    func loadCurrentData()
    func getItemCount() -> Int
    func getItemFor(_ indexPath: IndexPath) -> CommonSelectableCellModel
    func saveSelectedState(_ indexPath: IndexPath)
}

protocol UnitSceneViewModelOutputDelegate: AnyObject {
    func updateTableView(index: Int)
}
