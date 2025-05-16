//
//  LanguageSceneContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

protocol LanguageSceneViewModelProcotol: AnyObject {
    var delegate: LanguageSceneViewModelOutputDelegate? { get set }
    func loadCurrentData()
    func getItemCount() -> Int
    func getItemFor(_ indexPath: IndexPath) -> CommonSelectableCellModel
    func saveSelectedState(_ indexPath: IndexPath)
}

protocol LanguageSceneViewModelOutputDelegate: AnyObject {
    func updateTableView(index: Int)
}
