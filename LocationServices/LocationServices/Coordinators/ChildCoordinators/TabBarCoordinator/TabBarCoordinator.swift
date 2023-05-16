//
//  TabBarCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

protocol TabBarCoordinatorProtocol: Coordinator {
    var tabBarController: UITabBarController { get set }
}

final class TabBarCoordinator: NSObject, TabBarCoordinatorProtocol {

    var tabBarController: UITabBarController
    weak var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .main }

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 10)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.amazonFont(type: .medium, size: 10)], for: .selected)
    }

    func start() {
        createTabBarController(with: getAllPages())
    }
}

private extension TabBarCoordinator {
    func createTabBarController(with viewControllers: [UIViewController]) {
        tabBarController.setViewControllers(viewControllers, animated: true)
        tabBarController.tabBar.clipsToBounds = true
        tabBarController.hidesBottomBarWhenPushed = false
        tabBarController.selectedIndex = TabBarPage.explore.pageOrder
        tabBarController.tabBar.isTranslucent = false
        tabBarController.view.backgroundColor = .tabBarBackgroundColor
        tabBarController.tabBar.tintColor = .lsPrimary
        tabBarController.tabBar.unselectedItemTintColor = .tabBarUnselectedColor
        tabBarController.delegate = self
        navigationController.navigationBar.isHidden = true
        navigationController.setViewControllers([tabBarController], animated: true)
    }
}

private extension TabBarCoordinator {
    func getAllPages() -> [UINavigationController] {
        let allPages: [TabBarPage] = [.explore, .tracking, .geofence, .settings, .about]
        return allPages.map { getTabBarController($0) }
    }

    func getTabBarController(_ page: TabBarPage) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(title: page.title,
                                                       image: page.pageIcon,
                                                       tag: page.pageOrder)
        
        navigationController.tabBarItem.accessibilityIdentifier = page.accessbilityIdentifier
        switch page {
        case .explore: startExploreScene(navigationController)
        case .tracking: startTrackingScene(navigationController)
        case .geofence: startGeofenceScene(navigationController)
        case .about: startAboutScene(navigationController)
        case .settings: startSettingsScene(navigationController)
        }

        return navigationController
    }

    func startExploreScene(_ navigationController: UINavigationController) {
        let exploreCoordinator = ExploreCoordinator(navigationController: navigationController)
        exploreCoordinator.delegate = self
        exploreCoordinator.geofenceHandler = {
            self.tabBarController.selectedIndex = TabBarPage.geofence.pageOrder
        }
        childCoordinators.append(exploreCoordinator)
        exploreCoordinator.start()
    }

    func startTrackingScene(_ navigationController: UINavigationController) {
        let exploreCoordinator = TrackingCoordinator(navigationController: navigationController)
        exploreCoordinator.delegate = self
        exploreCoordinator.didSendEventClosure = {
            self.tabBarController.selectedIndex = TabBarPage.geofence.pageOrder
        }
        
        exploreCoordinator.didSendDirectionEvent = {
            self.tabBarController.selectedIndex = TabBarPage.explore.pageOrder
            self.childCoordinators.removeAll()
            let exploreCoordinator = ExploreCoordinator(navigationController: navigationController)
            exploreCoordinator.delegate = self
            self.childCoordinators.append(exploreCoordinator)
            exploreCoordinator.showDirections(isRouteOptionEnabled: nil, firstDestionation: nil, secondDestionation: nil, lat: nil, long: nil)
            
        }
        childCoordinators.append(exploreCoordinator)
        exploreCoordinator.start()
        
    }

    func startGeofenceScene(_ navigationController: UINavigationController) {
        let exploreCoordinator = GeofenceCoordinator(navigationController: navigationController)
        exploreCoordinator.delegate = self
        exploreCoordinator.directionHandler = {
            self.tabBarController.selectedIndex = TabBarPage.explore.pageOrder
            self.childCoordinators.removeAll()
            let exploreCoordinator = ExploreCoordinator(navigationController: navigationController)
            exploreCoordinator.delegate = self
            self.childCoordinators.append(exploreCoordinator)
            exploreCoordinator.showDirections(isRouteOptionEnabled: nil, firstDestionation: nil,
                                              secondDestionation: nil, lat: nil, long: nil)
        }
        childCoordinators.append(exploreCoordinator)
        exploreCoordinator.start()
    }

    func startSettingsScene(_ navigationController: UINavigationController) {
        let exploreCoordinator = SettingsCoordinator(navigationController: navigationController)
        exploreCoordinator.delegate = self
        childCoordinators.append(exploreCoordinator)
        exploreCoordinator.start()
    }

    func startAboutScene(_ navigationController: UINavigationController) {
        let coordinator = AboutCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}


extension TabBarCoordinator: CoordinatorCompletionDelegate {
    func didComplete(completedCoordinator: Coordinator) {
        self.delegate?.didComplete(completedCoordinator: self)
    
    }
}

extension TabBarCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        NotificationCenter.default.post(name: Notification.tabSelected, object: self, userInfo: ["viewController": viewController])
    }
}
