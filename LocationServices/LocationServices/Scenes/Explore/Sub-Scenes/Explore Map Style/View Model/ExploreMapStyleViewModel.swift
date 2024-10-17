//
//  ExploreMapStyleViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class ExploreMapStyleViewModel: ExploreMapStyleViewModelProtocol {
    var delegate: ExploreMapStyleViewModelOutputDelegate?
    

    func loadData() {
        let index = getDataFromLocal()
        delegate?.updateTableView(item: index)
    }
    
    func updateDataProviderWithMap(index: Int) {
        let mapStyle = DefaultUserSettings.mapStyle
        let mapStyleColorType = DefaultUserSettings.mapStyleColorType
        UserDefaultsHelper.saveObject(value: mapStyle, key: .mapStyle)
        UserDefaultsHelper.saveObject(value: mapStyleColorType, key: .mapStyleColorType)
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
        delegate?.updateTableView(item: index)
    }
    
    func getItemsCount() -> Int {
        1
    }
}

private extension ExploreMapStyleViewModel {
    func getDataFromLocal() -> Int {
        var currentIndex = 0
        return currentIndex
    }
}
