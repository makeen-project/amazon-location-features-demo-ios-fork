//
//  UnitTypes.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

enum UnitTypes: Codable  {
    case automatic, imperial, metric
    
    var title: String {
        switch self {
        case .automatic:
            return StringConstant.automaticUnit
        case .imperial:
            return StringConstant.imperialUnit
        case .metric:
            return StringConstant.metricUnit
        }
    }
    
    var subTitle: String {
        switch self {
        case .automatic:
            return "\(StringConstant.automaticUnit) (\(UnitHelper.getLocaleUnit().subTitle))"
        case .imperial:
            return StringConstant.imperialSubtitle
        case .metric:
            return StringConstant.metricSubtitle
        }
    }
}
