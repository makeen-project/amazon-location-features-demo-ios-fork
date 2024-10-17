//
//  DataProviderViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

enum DataProviderName {
    case here
    
    var title: String {
        switch self {
        case .here:
            return "HERE"
        }
    }
}

final class DataProviderViewModel: DataProviderViewModelProtocol {
    
    
    private var initialDatas: [CommonSelectableCellModel] = [
        CommonSelectableCellModel(title: DataProviderName.here.title,
                                  subTitle: nil,
                                  isSelected: true,
                                  identifier: ViewsIdentifiers.General.mapStyleRow)
    ]
    
    var delegate: DataProviderViewModelOutputDelegate?
    
    func getItemCount() -> Int {
        initialDatas.count
    }
    
    func getItemFor(_ indexPath: IndexPath) -> CommonSelectableCellModel {
        initialDatas[indexPath.row]
    }
    
    
    func loadData() {
        let index = 0
        delegate?.updateTableView(index: index)
    }
    
    func saveSelectedState(_ indexPath: IndexPath) {
        let title = initialDatas[indexPath.row].title
        saveUnitSettingsData(title: title)
        delegate?.updateTableView(index: indexPath.row)
    }
}

private extension DataProviderViewModel {
    func saveUnitSettingsData(title: String) {
        UserDefaultsHelper.saveObject(value: DefaultUserSettings.mapStyle, key: .mapStyle)
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
    }
}
