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

    case explore, tracking, settings, about

    var title: String {
        switch self {
        case .explore: return StringConstant.TabBar.explore
        case .tracking: return StringConstant.TabBar.tracking
        case .settings: return StringConstant.TabBar.settings
        case .about: return StringConstant.TabBar.about
        }
    }

    var pageIcon: UIImage {
        switch self {
        case .explore: return UIImage.exploreIcon
        case .tracking: return UIImage.trackingIcon
        case .settings: return UIImage.settingsIcon
        case .about: return UIImage.about
        }
    }

    var pageOrder: Int {
        switch self {
        case .explore: return PageOrder.first.rawValue
        case .tracking: return PageOrder.second.rawValue
        case .settings: return PageOrder.fourth.rawValue
        case .about: return PageOrder.fifth.rawValue
        }
    }
    
    var accessbilityIdentifier: String {
        switch self {
        case .explore: return ViewsIdentifiers.General.exploreTabBarButton
        case .tracking: return ViewsIdentifiers.General.trackingTabBarButton
        case .settings: return ViewsIdentifiers.General.settingsTabBarButton
        case .about: return ViewsIdentifiers.General.aboutTabBarButton
        }
    }
}
