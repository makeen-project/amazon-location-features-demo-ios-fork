//
//  SettingsViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class SettingsViewModel: SettingsViewModelProtocol {
    var delegate: SettingsViewModelOutputDelegate?
    private var datas: [SettingsCellModel] = []
    
    var awsLoginService: AWSLoginService! {
        didSet {
            awsLoginService.delegate = self
        }
    }
    
    func loadData() {
        populateConfiguredData()
        delegate?.refreshViews()
    }
    
    func getCellItems(_ indexPath: IndexPath) -> SettingsCellModel {
        return datas[indexPath.row]
    }
    
    func getItemCount() -> Int {
        datas.count
    }
    
    func logOut() {
        DispatchQueue.main.async {
            self.awsLoginService.logout()
            NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
        }
    }
    
    private func populateConfiguredData() {
        let mapStyle = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        let unitType = UserDefaultsHelper.get(for: String.self, key: .unitType)
    
        datas = [
            SettingsCellModel(type: .dataProvider, subTitle: mapStyle?.type.title ?? ""),
            SettingsCellModel(type: .mapStyle, subTitle: mapStyle?.title ?? ""),
            SettingsCellModel(type: .routeOption),
            SettingsCellModel(type: .awsCloud)
        ]
    }
}

extension SettingsViewModel: AWSLoginServiceOutputProtocol {
    func logoutResult(_ error: Error?) {
        NotificationCenter.default.post(name: Notification.updateSearchTextBarIconLogoutState, object: nil, userInfo: nil)
        delegate?.logoutCompleted()
    }
    
    func loginResult(_ result: Result<Void, Error>) {
        print("Logged in")
    }
}
