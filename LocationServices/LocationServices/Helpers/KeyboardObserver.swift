//
//  KeyboardObserver.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

class KeyboardObserver {
    static let shared: KeyboardObserver = KeyboardObserver()
    
    private(set) var keyboardHeight: CGFloat = 0
    
    private init() {
        setupKeyboardNotifications()
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeNotificationObservers(_:)), name: Notification.removeNotificationObservers, object: nil)
    }
    
    @objc func removeNotificationObservers(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardHeight = keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = 0
    }
}
