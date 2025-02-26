//
//  SettingsDefaultValueHelper.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class SettingsDefaultValueHelper {
    
    static var shared = SettingsDefaultValueHelper()
    
    func createValues() {
        if UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle) == nil {
            UserDefaultsHelper.saveObject(value: DefaultUserSettings.mapStyle, key: .mapStyle)
        }
        
        if UserDefaultsHelper.getObject(value: MapStyleColorType.self, key: .mapStyleColorType) == nil {
            UserDefaultsHelper.saveObject(value: DefaultUserSettings.mapStyleColorType, key: .mapStyleColorType)
        }
        
        if UserDefaultsHelper.getObject(value: UnitTypes.self, key: .unitType) == nil {
            UserDefaultsHelper.saveObject(value: DefaultUserSettings.unitValue, key: .unitType)
        }
        
        if UserDefaultsHelper.get(for: Bool.self, key: .tollOptions) == nil {
            UserDefaultsHelper.save(value: true, key: .tollOptions)
        }
        
        if UserDefaultsHelper.get(for: Bool.self, key: .ferriesOptions) == nil {
            UserDefaultsHelper.save(value: true, key: .ferriesOptions)
        }        
    }
}
