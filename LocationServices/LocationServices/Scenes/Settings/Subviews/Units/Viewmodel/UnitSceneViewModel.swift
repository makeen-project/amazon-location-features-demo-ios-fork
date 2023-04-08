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
        CommonSelectableCellModel(title: "Automatic",
                                  subTitle: nil,
                                  isSelected: true,
                                  identifier: "Automatic"),
        CommonSelectableCellModel(title: "Imperial",
                                  subTitle: "Miles, pounds",
                                  isSelected: false,
                                  identifier: "Imperial"),
        CommonSelectableCellModel(title: "Metric",
                                  subTitle: "Kilometers, kilograms",
                                  isSelected: false,
                                  identifier: "Metric")
    ]
    func loadCurrentData() {
        let index =  getDataFromLocal()
        delegate?.updateTableView(index: index)
    }
    
    func getItemCount() -> Int {
        initialDatas.count
    }
    
    func getItemFor(_ indexPath: IndexPath) -> CommonSelectableCellModel {
        initialDatas[indexPath.row]
    }
    
    func saveSelectedState(_ indexPath: IndexPath) {
        let title = initialDatas[indexPath.row].title
        saveUnitSettingsData(title: title)
        delegate?.updateTableView(index: indexPath.row)
    }
}

private extension UnitSceneViewModel {
    func getDataFromLocal() -> Int {
        var currentDataIndex = 0
        let localData =  UserDefaultsHelper.get(for: String.self, key: .unitType)
        
        for index in initialDatas.indices {
            if initialDatas[index].title == localData {
                currentDataIndex = index
                initialDatas[index].isSelected = true
            } else {
                initialDatas[index].isSelected = false
            }
        }
        return currentDataIndex
    }
    
    func saveUnitSettingsData(title: String) {
        UserDefaultsHelper.save(value: title, key: .unitType)
    }
}
