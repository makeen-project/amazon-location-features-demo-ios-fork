//
//  DataProviderProtocol.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

protocol DataProviderViewModelProtocol: AnyObject {
    var delegate: DataProviderViewModelOutputDelegate? { get set }
    func loadData()
    func getItemCount() -> Int
    func getItemFor(_ indexPath: IndexPath) -> CommonSelectableCellModel
    func saveSelectedState(_ indexPath: IndexPath)
}

protocol DataProviderViewModelOutputDelegate: AnyObject {
    func updateTableView(index: Int)
}
