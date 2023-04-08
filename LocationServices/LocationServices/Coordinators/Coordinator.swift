//
//  Coordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

enum CoordinatorType {
    case main, login, explore, tracking, geofence, settings, more
}

protocol CoordinatorCompletionDelegate: AnyObject {
    func didComplete(completedCoordinator: Coordinator)
}

protocol Coordinator: AnyObject {
    var delegate: CoordinatorCompletionDelegate? { get set }
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    var type: CoordinatorType { get }
    func start()
    func complete()

}

extension Coordinator {
    func complete() {
        childCoordinators.removeAll()
        delegate?.didComplete(completedCoordinator: self)
    }
}
