//
//  RegionTypes.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

enum RegionTypes: Codable  {
    case automatic, euWest1, usEast1
    
    var title: String {
        switch self {
        case .automatic:
            return StringConstant.automaticUnit
        case .euWest1:
            return StringConstant.euWest1
        case .usEast1:
            return StringConstant.usEast1
        }
    }
    
    var displayTitle: String {
        switch self {
        case .automatic:
            return StringConstant.automaticUnit
        case .euWest1:
            return StringConstant.euWest1FullName
        case .usEast1:
            return StringConstant.usEast1FullName
        }
    }
    
    var listTitle: String {
        switch self {
        case .automatic:
            return StringConstant.automaticUnit
        case .euWest1:
            return StringConstant.euWest1ListTitle
        case .usEast1:
            return StringConstant.usEast1ListTitle
        }
    }
    
}
