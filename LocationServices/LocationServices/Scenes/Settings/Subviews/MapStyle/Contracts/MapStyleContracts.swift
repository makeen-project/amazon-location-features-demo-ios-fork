//
//  MapStyleContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

protocol MapStyleViewModelProtocol: AnyObject {
    var delegate: MapStyleViewModelOutputDelegate? { get set }
    func getSectionsCount() -> Int
    func getItemCount(at section: Int) -> Int
    func getSectionTitle(at section: Int) -> String
    func getCellItem(_ indexPath: IndexPath) -> MapStyleCellModel?
    func saveSelectedState(_ indexPath: IndexPath)
    func loadLocalMapData()
}

protocol MapStyleViewModelOutputDelegate: AnyObject {
    func loadData(selectedIndexPath: IndexPath)
}
