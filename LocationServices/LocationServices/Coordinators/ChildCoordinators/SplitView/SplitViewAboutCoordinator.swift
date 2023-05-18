//
//  SplitViewAboutCoordinator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SafariServices

final class SplitViewAboutCoordinator: Coordinator {
    var delegate: CoordinatorCompletionDelegate?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController = UINavigationController()
    var type: CoordinatorType { .explore }
    
    private let splitViewController: UISplitViewController

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
    }

    func start() {
        showAboutScene()
    }
}

private extension SplitViewAboutCoordinator {
    func showAboutScene() {
        let controller = AboutVCBuilder.create()
        controller.delegate = self
        splitViewController.setViewController(controller, for: .supplementary)
        splitViewController.show(.supplementary)
        showNextScene(type: .attribution)
        splitViewController.viewController(for: .secondary)?.navigationController?.navigationBar.isHidden = false
    }
}

extension SplitViewAboutCoordinator: AboutNavigationDelegate {
    func showNextScene(type: AboutCellType) {
        switch type {
        case .attribution:
            showAttributionScene()
        case .termsAndConditions:
            showTermsAndConditionsScene()
        case .version:
            showVersionScene()
        case .help:
            showHelpScene()
        }
    }
    
    private func showAttributionScene() {
        let controller = AttributionVCBuilder.create()
        changeSecondaryVC(to: controller)
    }
    
    private func showVersionScene() {
        let controller = VersionVCBuilder.create()
        changeSecondaryVC(to: controller)
    }
    
    private func showTermsAndConditionsScene() {
        let controller = TermsAndConditionsVCBuilder.create()
        changeSecondaryVC(to: controller)
    }
    
    private func showHelpScene() {
        let controller = WebViewVCBuilder.create(rawUrl: StringConstant.helpURL)
        changeSecondaryVC(to: controller)
    }
    
    private func openSafariBrowser(with url: URL?) {
        guard let url else {
            let alertModel = AlertModel(title: StringConstant.error, message: StringConstant.invalidUrlError, cancelButton: nil)
            splitViewController.showAlert(alertModel)
            return
        }
        
        let controller = SFSafariViewController(url: url)
        changeSecondaryVC(to: controller)
    }
    
    private func changeSecondaryVC(to viewController: UIViewController) {
        splitViewController.changeSecondaryViewController(to: viewController)
        splitViewController.show(.secondary)
    }
}
