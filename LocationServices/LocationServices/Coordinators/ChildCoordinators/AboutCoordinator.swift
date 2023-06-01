//
//  AboutCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SafariServices

final class AboutCoordinator: Coordinator {
    var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CoordinatorType { .explore }

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showAboutScene()
    }
}

private extension AboutCoordinator {
    func showAboutScene() {
        let controller = AboutVCBuilder.create()
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }
}

extension AboutCoordinator: AboutNavigationDelegate {
    func showNextScene(type: AboutCellType) {
        switch type {
        case .attribution:
            showAttributionScene()
        case .termsAndConditions:
            showTermsAndConditionsScene()
        case .version:
            showVersionScene()
        case .help:
            openSafariBrowser(with: URL(string: StringConstant.helpURL))
        }
    }
    
    private func showAttributionScene() {
        let controller = AttributionVCBuilder.create()
        controller.closeCallback = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(controller, animated: true)
    }
    
    private func showVersionScene() {
        let controller = VersionVCBuilder.create()
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
