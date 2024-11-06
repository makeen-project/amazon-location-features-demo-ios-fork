//
//  ExploreMapStyleContract.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

protocol ExploreMapStyleViewModelProtocol: AnyObject {
    var delegate: ExploreMapStyleViewModelOutputDelegate? { get set }
    func getItemsCount() -> Int
    func loadData()
    func updateDataProviderWithMap(index: Int)
}

protocol ExploreMapStyleViewModelOutputDelegate: AnyObject {
    func updateTableView(item: Int)
}

protocol ExploreMapStyleCellViewModelProtocol: AnyObject {
    var delegate: ExploreMapStyleCellViewModelOutputDelegate? { get set }
    func loadLocalMapData()
    func getItemCount() -> Int
    func getCellItem(_ indexPath: IndexPath) -> MapStyleCellModel
    func saveSelectedState(_ indexPath: IndexPath)
}

protocol ExploreMapStyleCellViewModelOutputDelegate: AnyObject {
    func loadData(selectedIndex: Int?)
}
