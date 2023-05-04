//
//  UISplitViewController+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension UISplitViewController {
    func changeSecondaryViewController(to viewController: UIViewController) {
        if let secondaryViewController = self.viewController(for: .secondary) {
            secondaryViewController.navigationController?.setViewControllers([viewController], animated: false)
        } else {
            setViewController(viewController, for: .secondary)
        }
    }
}
