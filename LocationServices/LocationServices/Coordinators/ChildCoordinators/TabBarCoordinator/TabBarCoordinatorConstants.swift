//
//  TabBarCoordinatorConstants.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

enum TabBarPage {
    enum PageOrder: Int {
        case first = 0, second, third, fourth, fifth
    }

    case explore, tracking, geofence, settings, more

    var title: String {
        switch self {
        case .explore: return "Explore"
        case .tracking: return "Tracking"
        case .geofence: return "Geofence"
        case .settings: return "Settings"
        case .more: return "More"
        }
    }

    var pageIcon: UIImage {
        switch self {
        case .explore: return UIImage.exploreIcon
        case .tracking: return UIImage.trackingIcon
        case .geofence: return UIImage.geofenceIcon
        case .settings: return UIImage.settingsIcon
        case .more: return UIImage.moreIcon
        }
    }

    var pageOrder: Int {
        switch self {
        case .explore: return PageOrder.first.rawValue
        case .tracking: return PageOrder.second.rawValue
        case .geofence: return PageOrder.third.rawValue
        case .settings: return PageOrder.fourth.rawValue
        case .more: return PageOrder.fifth.rawValue
        }
    }
}
