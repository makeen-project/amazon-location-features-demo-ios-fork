//
//  MapStyleViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class MapStyleViewModel: MapStyleViewModelProtocol {
    
    private let mapStyles: [MapStyleModel]
    var delegate: MapStyleViewModelOutputDelegate?
    
    init() {
        mapStyles = DefaultMapStyles.mapStyles
    }
    
    func getSectionsCount() -> Int {
        return 1
    }
    
    func getSectionTitle(at section: Int) -> String {
        return "Map Style"
    }
    
    func getItemCount(at section: Int) -> Int {
        return mapStyles.count
    }
    
    func getCellItem(_ indexPath: IndexPath) -> MapStyleCellModel? {
        let style = mapStyles[indexPath.row]
        return MapStyleCellModel(model: style)
    }
    
    func saveSelectedState(_ indexPath: IndexPath) {
        let item = mapStyles[indexPath.row]
        
        saveUnitSettingsData(mapStyle: item)
        delegate?.loadData(selectedIndexPath: indexPath)
    }
    
    func loadLocalMapData() {
        let selectedIndex = loadCurentSourceMap() ?? IndexPath(row: 0, section: 0)
        delegate?.loadData(selectedIndexPath: selectedIndex)
    }
}

private extension MapStyleViewModel {
    
    func loadCurentSourceMap() -> IndexPath? {
        guard let localData = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle) else { return nil }
        
        let section = 0
        let row = mapStyles.firstIndex(where: { $0.title == localData.title })
        return IndexPath(row: row!, section: section)
    }
    
    func saveUnitSettingsData(mapStyle: MapStyleModel) {
        UserDefaultsHelper.saveObject(value: mapStyle, key: .mapStyle)
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.validateMapColor, object: nil, userInfo: nil)
    }
}
