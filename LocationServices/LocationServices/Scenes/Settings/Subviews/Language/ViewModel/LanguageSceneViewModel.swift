//
//  LanguageSceneViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import UIKit
final class LanguageSceneViewModel: LanguageSceneViewModelProcotol {
    
    var delegate: LanguageSceneViewModelOutputDelegate?
    
    private var initialDatas: [CommonSelectableCellModel] = []
    
    init() {
        for language in languageSwitcherData {
            if !language.mapOnly {
                initialDatas.append(CommonSelectableCellModel(title: language.label,
                                          subTitle: "",
                                          isSelected: false,
                                          identifier: language.value))
            }
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
        let language = initialDatas[indexPath.row].identifier
        saveLanguageSettingsData(language: language)
        delegate?.updateTableView(index: indexPath.row)
    }
}

private extension LanguageSceneViewModel {
    func getDataFromLocal() -> Int {
        var currentDataIndex = 0
        let localData = Locale.currentAppLanguageIdentifier()
         
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
    
    func saveLanguageSettingsData(language: String) {
        // Reload root view controller or restart UI
        LanguageManager.shared.currentLanguage = language
        LanguageManager.shared.reloadRootViewController()
    }
}
