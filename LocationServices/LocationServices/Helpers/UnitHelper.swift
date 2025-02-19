//
//  UnitHelper.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

class UnitHelper {
    public static func getLocaleUnit() -> UnitTypes {
        let locale = Locale.current
        let nonMetricCountries: Set<String> = ["US", "MM", "LR"]
        return nonMetricCountries.contains(locale.region?.identifier.uppercased() ?? "") ? UnitTypes.imperial : UnitTypes.metric
    }
    
    public static func getResolvedUnit() -> UnitTypes? {
        let unitType = UserDefaultsHelper.getObject(value: UnitTypes.self, key: .unitType)
        if unitType == .automatic {
            return getLocaleUnit()
        }
        else {
            return unitType
        }
    }
}
