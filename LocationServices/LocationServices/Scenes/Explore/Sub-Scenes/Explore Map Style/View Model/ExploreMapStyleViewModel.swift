//
//  ExploreMapStyleViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class ExploreMapStyleViewModel: ExploreMapStyleViewModelProtocol {
    var delegate: ExploreMapStyleViewModelOutputDelegate?
    
    private var datas: [MapStyleSourceType] =  [.esri, .here]
    
    func loadData() {
        let index = getDataFromLocal()
        delegate?.updateTableView(item: index)
    }
    
    func updateDataProviderWithMap(index: Int) {
        let mapStyle: MapStyleModel
        switch getItem(with: index) {
        case .esri:
            mapStyle = DefaultUserSettings.mapStyle
        case .here:
            mapStyle = DefaultUserSettings.mapHereStyle
        }
        UserDefaultsHelper.saveObject(value: mapStyle, key: .mapStyle)
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
        delegate?.updateTableView(item: index)
    }
    
    func getItemsCount() -> Int {
        datas.count
    }
    
    func getItem(with index: Int) -> MapStyleSourceType {
        datas[index]
    }
    
}

private extension ExploreMapStyleViewModel {
    func getDataFromLocal() -> Int {
        let localData = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        
        var currentIndex = 0
        if let type = localData?.type,
           let index = datas.firstIndex(of: type) {
            currentIndex = index
        }
        
        return currentIndex
    }
}
