//
//  SettingsContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol SettingsViewModelProtocol: AnyObject {
    var delegate: SettingsViewModelOutputDelegate? { get set}
    func loadData()
    func getItemCount() -> Int
    func getCellItems(_ indexPath: IndexPath) -> SettingsCellModel
//    func logOut()
//    func disconnectAWS()
}

protocol SettingsViewModelOutputDelegate: AnyObject, AlertPresentable {
    func refreshViews()
    //func logoutCompleted()
}

protocol SettingsNavigationDelegate: AnyObject {
    func showNextScene(type: SettingsCellType)
}
