//
//  RegionSceneViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
final class RegionSceneViewModel: RegionSceneViewModelProcotol {
    
    var delegate: RegionSceneViewModelOutputDelegate?
    
    private var initialDatas: [CommonSelectableCellModel] = []
    init() {
        let awsRegion = RegionSelector.shared.getCachedRegion()
        initialDatas.append(CommonSelectableCellModel(title: "\(StringConstant.automaticUnit) - \(awsRegion ?? "")",
                                                      subTitle: "",
                                                      isSelected: true,
                                                      identifier: StringConstant.automaticUnit))
        RegionSelector.shared.getBundleRegions()?.forEach {
            var title = ""
            if $0 == RegionTypes.euWest1.title {
                title = RegionTypes.euWest1.displayTitle
            }
            else if $0 == RegionTypes.usEast1.title {
                title = RegionTypes.usEast1.displayTitle
            }
            initialDatas.append(CommonSelectableCellModel(title: title,
                                                          subTitle: "",
                                                          isSelected: false,
                                                          identifier: $0))
        }
    }
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
        let region = initialDatas[indexPath.row].identifier
        saveRegionSettingsData(region: region)
        delegate?.updateTableView(index: indexPath.row)
    }
}

private extension RegionSceneViewModel {
    func getDataFromLocal() -> Int {
        var currentDataIndex = 0
        let localData = RegionSelector.shared.getCachedRegion()
        let isAutoRegion = RegionSelector.shared.isAutoRegion()
        
        if isAutoRegion == true {
            for index in initialDatas.indices {
                initialDatas[index].isSelected = false
            }
            currentDataIndex = 0
            initialDatas[0].isSelected = true
        } else {
            for index in initialDatas.indices {
                if initialDatas[index].identifier == localData {
                    currentDataIndex = index
                    initialDatas[index].isSelected = true
                } else {
                    initialDatas[index].isSelected = false
                }
            }
        }
        return currentDataIndex
    }
    
    func saveRegionSettingsData(region: String) {
        if region == StringConstant.automaticUnit {
            RegionSelector.shared.clearCachedRegion()
            if let bundleRegions = RegionSelector.shared.getBundleRegions() {
                RegionSelector.shared.setClosestRegion(apiRegions: bundleRegions) { detectedRegion in
                    if let detectedRegion = detectedRegion {
                        RegionSelector.shared.saveCachedRegion(region: detectedRegion, isAutoRegion: true)
                    }
                }
            }
        } else {
            RegionSelector.shared.saveCachedRegion(region: region, isAutoRegion: false)
        }
        GeneralHelper.reloadUI()
    }
}
