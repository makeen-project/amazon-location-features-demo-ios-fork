//
//  DataProviderViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

enum DataProviderName {
    case here, esri
    
    var title: String {
        switch self {
        case .esri:
            return "Esri"
        case .here:
            return "HERE"
        }
    }
    
    var placeIndexesName: String {
        switch self {
        case .esri:
            return "location.aws.com.demo.places.Esri.PlaceIndex"
        case .here:
            return "location.aws.com.demo.places.HERE.PlaceIndex"
        }
    }
    
    var routeCalculator: String {
        switch self {
        case .esri:
            return "location.aws.com.demo.routes.Esri.RouteCalculator"
        case .here:
            return "location.aws.com.demo.routes.HERE.RouteCalculator"
        }
    }
}

final class DataProviderViewModel: DataProviderViewModelProtocol {
    
    
    private var initialDatas: [CommonSelectableCellModel] = [
        CommonSelectableCellModel(title: DataProviderName.esri.title,
                                  subTitle: nil,
                                  isSelected: false,
                                  identifier: MapStyleSourceType.esri.title),
        CommonSelectableCellModel(title: DataProviderName.here.title,
                                  subTitle: nil,
                                  isSelected: true,
                                  identifier: MapStyleSourceType.here.title)
    ]
    
    var delegate: DataProviderViewModelOutputDelegate?
    
    func getItemCount() -> Int {
        initialDatas.count
    }
    
    func getItemFor(_ indexPath: IndexPath) -> CommonSelectableCellModel {
        initialDatas[indexPath.row]
    }
    
    
    func loadData() {
        let index =  getDataFromLocal()
        delegate?.updateTableView(index: index)
    }
    
    func saveSelectedState(_ indexPath: IndexPath) {
        let title = initialDatas[indexPath.row].title
        saveUnitSettingsData(title: title)
        delegate?.updateTableView(index: indexPath.row)
    }
}

private extension DataProviderViewModel {
    func getDataFromLocal() -> Int {
        var currentDataIndex = 0
        let localData = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        
        for index in initialDatas.indices {
            let isSelected = initialDatas[index].title == localData?.type.title
            initialDatas[index].isSelected = isSelected
            if isSelected {
                currentDataIndex = index
            }
        }
        return currentDataIndex
    }
    
    func saveUnitSettingsData(title: String) {
        if title == DataProviderName.here.title {
            UserDefaultsHelper.saveObject(value: DefaultUserSettings.mapHereStyle, key: .mapStyle)
        } else {
            UserDefaultsHelper.saveObject(value: DefaultUserSettings.mapStyle, key: .mapStyle)
        }
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
    }
}
