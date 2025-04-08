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
            return "Automatic"
        case .imperial:
            return "Imperial"
        case .metric:
            return "Metric"
        }
    }
    
    var subTitle: String {
        switch self {
        case .automatic:
            return "Based on your browser settings (\(UnitHelper.getLocaleUnit().subTitle))"
        case .imperial:
            return "Miles, pounds"
        case .metric:
            return "Kilometers, kilograms"
        }
    }
}
