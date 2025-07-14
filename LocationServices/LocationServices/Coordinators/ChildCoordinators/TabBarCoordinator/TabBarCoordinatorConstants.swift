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

    case navigate, tracking, settings, more

    var title: String {
        switch self {
        case .navigate: return StringConstant.TabBar.navigate
        case .tracking: return StringConstant.TabBar.tracking
        case .settings: return StringConstant.TabBar.settings
        case .more: return StringConstant.TabBar.more
        }
    }

    var pageIcon: UIImage {
        switch self {
        case .navigate: return UIImage.navigateIcon
        case .tracking: return UIImage.trackingIcon
        case .settings: return UIImage.settingsIcon
        case .more: return UIImage.moreIcon
        }
    }

    var pageOrder: Int {
        switch self {
        case .navigate: return PageOrder.first.rawValue
        case .tracking: return PageOrder.second.rawValue
        case .settings: return PageOrder.fourth.rawValue
        case .more: return PageOrder.fifth.rawValue
        }
    }
    
    var accessbilityIdentifier: String {
        switch self {
        case .navigate: return ViewsIdentifiers.General.navigateTabBarButton
        case .tracking: return ViewsIdentifiers.General.trackingTabBarButton
        case .settings: return ViewsIdentifiers.General.settingsTabBarButton
        case .more: return ViewsIdentifiers.General.navigateTabBarButton
        }
    }
}
