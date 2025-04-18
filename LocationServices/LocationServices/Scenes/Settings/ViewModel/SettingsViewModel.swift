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
    
//    var awsLoginService: AWSLoginService! {
//        didSet {
//            awsLoginService.delegate = self
//        }
//    }
    
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
    
//    func logOut() {
//        let alertModel = AlertModel(title: StringConstant.logout, message: StringConstant.logoutAlertMessage) {
//            [weak self] in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.awsLoginService.logout()
//                NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
//                self.delegate?.logoutCompleted()
//            }
//        }
//        delegate?.showAlert(alertModel)
//    }
//    
//    func disconnectAWS() {
//        let alertModel = AlertModel(title: StringConstant.disconnectAWS, message: StringConstant.disconnectAWSAlertMessage) {
//            [weak self] in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                self.awsLoginService.disconnectAWS()
//                NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
//                self.delegate?.logoutCompleted()
//            }
//        }
//        delegate?.showAlert(alertModel)
//    }
//    
    private func populateConfiguredData() {
        let mapStyle = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        let unitType = UserDefaultsHelper.getObject(value: UnitTypes.self, key: .unitType)

        datas = [
            SettingsCellModel(type: .units, subTitle: unitType?.title ?? ""),
            SettingsCellModel(type: .mapStyle, subTitle: mapStyle?.title ?? ""),
            SettingsCellModel(type: .routeOption)
        ]
    }
}

//extension SettingsViewModel: AWSLoginServiceOutputProtocol {
//    func logoutResult(_ error: Error?) {
//        NotificationCenter.default.post(name: Notification.updateSearchTextBarIconLogoutState, object: nil, userInfo: nil)
//        delegate?.logoutCompleted()
//    }
//    
//    func loginResult(_ result: Result<Void, Error>) {
//        switch result {
//        case .success():
//            print("Logged in")
//        case .failure(let error):
//            print("Logged in failure")
//        }
//    }
//}
