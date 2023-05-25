//
//  UIViewController+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension UIViewController {
    private static let statusBarBlurViewTag = 111
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func blurStatusBar(includeAdditionalSafeArea: Bool = false) {
        guard view.viewWithTag(Self.statusBarBlurViewTag) == nil else { return }
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.tag = Self.statusBarBlurViewTag
        view.addSubview(blurView)
        
        var offset: CGFloat = 0
        
        if let navigationController, !navigationController.navigationBar.isHidden {
            offset += navigationController.navigationBar.frame.height
        }
        if !includeAdditionalSafeArea {
            offset += navigationController?.additionalSafeAreaInsets.top ?? 0
        }
        
        blurView.snp.makeConstraints {
            $0.top.trailing.leading.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-offset)
        }
    }
}

extension UIViewController: AlertPresentable {}
