//
//  MapStyleViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class MapStyleViewModel: MapStyleViewModelProtocol {
    
    private let mapStyles: [MapStyleSourceType: [MapStyleModel]]
    private let sortedKeys: [MapStyleSourceType]
    
    var delegate: MapStyleViewModelOutputDelegate?
    
    init() {
        mapStyles = Dictionary(grouping: DefaultMapStyles.mapStyles) { $0.type }
        sortedKeys = Array(mapStyles.keys).sorted(by: { first, _ in first == .esri })
    }
    
    func getSectionsCount() -> Int {
        return sortedKeys.count
    }
    
    func getSectionTitle(at section: Int) -> String {
        return sortedKeys[section].title
    }
    
    func getItemCount(at section: Int) -> Int {
        return mapStyles[sortedKeys[section]]?.count ?? 0
    }
    
    func getCellItem(_ indexPath: IndexPath) -> MapStyleCellModel? {
        guard let style = mapStyles[sortedKeys[indexPath.section]]?[indexPath.row] else { return nil }
        return MapStyleCellModel(model: style)
    }
    
    func saveSelectedState(_ indexPath: IndexPath) {
        guard let item = mapStyles[sortedKeys[indexPath.section]]?[indexPath.row] else { return }
        
        saveUnitSettingsData(mapSource: item)
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
        
        guard let section = sortedKeys.firstIndex(of: localData.type) else { return nil }
        
        let mapStyles = self.mapStyles[localData.type]
        guard let row = mapStyles?.firstIndex(where: { $0.title == localData.title }) else { return nil }
        
        return IndexPath(row: row, section: section)
    }
    
    func saveUnitSettingsData(mapSource: MapStyleModel) {
        UserDefaultsHelper.saveObject(value: mapSource, key: .mapStyle)
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
    }
}
