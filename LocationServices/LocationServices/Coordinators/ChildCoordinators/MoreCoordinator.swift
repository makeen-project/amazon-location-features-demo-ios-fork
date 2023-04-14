//
//  MoreCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SafariServices

final class MoreCoordinator: Coordinator {
    var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .explore }

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showMoreScene()
    }
}

private extension MoreCoordinator {
    func showMoreScene() {
        let controller = MoreVCBuilder.create()
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }
}

extension MoreCoordinator: MoreNavigationDelegate {
    func showNextScene(type: MoreCellType) {
        switch type {
        case .attribution:
            showAttributionScene()
        case .termsAndConditions:
            showTermsAndConditionsScene()
        case .about:
            showAboutScene()
        case .help:
            openSafariBrowser(with: URL(string: StringConstant.helpURL))
        }
    }
    
    private func showAttributionScene() {
        let controller = AttributionVCBuilder.create()
        navigationController.pushViewController(controller, animated: true)
    }
    
    private func showAboutScene() {
        let controller = AboutVCBuilder.create()
        navigationController.pushViewController(controller, animated: true)
    }
    
    private func showTermsAndConditionsScene() {
        let controller = TermsAndConditionsVCBuilder.create()
        navigationController.pushViewController(controller, animated: true)
    }
    
    private func openSafariBrowser(with url: URL?) {
        guard let url else { return }
        
        let vc = SFSafariViewController(url: url)
        navigationController.present(vc, animated: true)
    }
}
