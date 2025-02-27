//
//  UnitSceneViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
final class UnitSceneViewModel: UnitSceneViewModelProcotol {
    
    var delegate: UnitSceneViewModelOutputDelegate?
    
    private var initialDatas: [CommonSelectableCellModel] = [
        CommonSelectableCellModel(title: UnitTypes.automatic.title,
                                  subTitle: UnitTypes.automatic.subTitle,
                                  isSelected: true,
                                  identifier: UnitTypes.automatic.title,
                                  unitType: UnitTypes.automatic),
        CommonSelectableCellModel(title: UnitTypes.imperial.title,
                                  subTitle: UnitTypes.imperial.subTitle,
                                  isSelected: false,
                                  identifier: UnitTypes.imperial.title,
                                  unitType: UnitTypes.imperial),
        CommonSelectableCellModel(title: UnitTypes.metric.title,
                                  subTitle: UnitTypes.metric.subTitle,
                                  isSelected: false,
                                  identifier: UnitTypes.metric.title,
                                  unitType: UnitTypes.metric)
    ]
    func loadCurrentData() {
        let index = getDataFromLocal()
        delegate?.updateTableView(index: index)
    }
    
    func getItemCount() -> Int {
        initialDatas.count
    }
    
    func getItemFor(_ indexPath: IndexPath) -> CommonSelectableCellModel {
        initialDatas[indexPath.row]
    }
    
    func saveSelectedState(_ indexPath: IndexPath) {
        if let unitType = initialDatas[indexPath.row].unitType {
            saveUnitSettingsData(unitType: unitType)
        }
        delegate?.updateTableView(index: indexPath.row)
    }
}

private extension UnitSceneViewModel {
    func getDataFromLocal() -> Int {
        var currentDataIndex = 0
        let localData =  UserDefaultsHelper.getObject(value: UnitTypes.self, key: .unitType)
        
        for index in initialDatas.indices {
            if initialDatas[index].title == localData?.title {
                currentDataIndex = index
                initialDatas[index].isSelected = true
            } else {
                initialDatas[index].isSelected = false
            }
        }
        return currentDataIndex
    }
    
    func saveUnitSettingsData(unitType: UnitTypes) {
        UserDefaultsHelper.saveObject(value: unitType, key: .unitType)
    }
}
