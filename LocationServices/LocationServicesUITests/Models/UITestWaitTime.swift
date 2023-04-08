//
//  UITestWaitTime.swift
//  LocationServicesUITests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

enum UITestWaitTime {
    case regular
    case navigation
    case request
    case long
    case map
    
    var time: TimeInterval {
        switch self {
        case .regular:
            return 5
        case .navigation:
            return 10
        case .request:
            return 30
        case .long:
            return 30
        case .map:
            return 60
        }
    }
}
