//
//  UISplitViewControllerDisplayMode+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension UISplitViewController.DisplayMode {
    func mapSearchState() -> MapSearchState {
        switch self {
        case .secondaryOnly:
            return .onlySecondaryVisible
        default:
            return .primaryVisible
        }
    }
    
    var isOnlySecondary: Bool {
        return self == .secondaryOnly
    }
}
