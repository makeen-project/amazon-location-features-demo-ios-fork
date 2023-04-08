//
//  ExploreMapStyleCellViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class ExploreMapStyleCellViewModel: ExploreMapStyleCellViewModelProtocol {
    private let mapStyles: [MapStyleModel]
    
    init(mapStyleSourceType: MapStyleSourceType) {
        self.mapStyles = DefaultMapStyles.mapStyles.filter { $0.type == mapStyleSourceType }
    }
    
    var delegate: ExploreMapStyleCellViewModelOutputDelegate?
    
    func loadLocalMapData()  {
        let selectedIndex = loadCurentSourceMap()
        delegate?.loadData(selectedIndex: selectedIndex)
    }
    
    func getItemCount() -> Int {
        mapStyles.count
    }
    
    func getCellItem(_ indexPath: IndexPath) -> MapStyleCellModel {
        let cellModel = mapStyles.map(MapStyleCellModel.init)
        return cellModel[indexPath.row]
    }
    
    func saveSelectedState(_ indexPath: IndexPath) {
        let item = mapStyles[indexPath.row]
        saveUnitSettingsData(mapSource: item)
        delegate?.loadData(selectedIndex: indexPath.row)
    }
}

private extension ExploreMapStyleCellViewModel {
    func loadCurentSourceMap() -> Int? {
        let localData = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        return mapStyles.firstIndex(where: { $0.title == localData?.title })
    }
    
    func saveUnitSettingsData(mapSource: MapStyleModel) {
        UserDefaultsHelper.saveObject(value: mapSource, key: .mapStyle)
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
    }
}
