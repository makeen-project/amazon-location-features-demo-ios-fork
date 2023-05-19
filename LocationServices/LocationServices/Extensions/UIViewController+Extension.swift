//
//  UIViewController+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func blurStatusBar() {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.addSubview(blurView)
        
        let offset = navigationController?.navigationBar.frame.height ?? 0
        
        blurView.snp.makeConstraints {
            $0.top.trailing.leading.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-offset)
        }
    }
}

extension UIViewController: AlertPresentable {}
