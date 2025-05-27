//
//  RegionSceneViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
final class RegionSceneViewModel: RegionSceneViewModelProcotol {
    
    var delegate: RegionSceneViewModelOutputDelegate?
    
    private var initialDatas: [CommonSelectableCellModel] = [
        CommonSelectableCellModel(title: RegionTypes.automatic.title,
                                  subTitle: "",
                                  isSelected: true,
                                  identifier: RegionTypes.automatic.title),
        CommonSelectableCellModel(title: RegionTypes.usEast1.title,
                                  subTitle: "",
                                  isSelected: false,
                                  identifier: RegionTypes.usEast1.title),
        CommonSelectableCellModel(title: RegionTypes.euWest1.title,
                                  subTitle: "",
                                  isSelected: false,
                                  identifier: RegionTypes.euWest1.title)
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
        let region = initialDatas[indexPath.row].title
        saveRegionSettingsData(region: region)
        delegate?.updateTableView(index: indexPath.row)
    }
}

private extension RegionSceneViewModel {
    func getDataFromLocal() -> Int {
        var currentDataIndex = 0
        let localData =  UserDefaultsHelper.getObject(value: String.self, key: .awsRegion)
        
        for index in initialDatas.indices {
            if initialDatas[index].identifier == localData {
                currentDataIndex = index
                initialDatas[index].isSelected = true
            } else {
                initialDatas[index].isSelected = false
            }
        }
        return currentDataIndex
    }
    
    func saveRegionSettingsData(region: String) {
        UserDefaultsHelper.saveObject(value: region, key: .awsRegion)
    }
}
