//
//  Textfield+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension UITextField {

    enum PaddingSide {
        case left(CGFloat)
        case right(CGFloat)
        case both(CGFloat)
    }

    func addPadding(_ padding: PaddingSide) {

        self.leftViewMode = .always
        self.layer.masksToBounds = true


        switch padding {

        case .left(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.leftView = paddingView
            self.rightViewMode = .always

        case .right(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.rightView = paddingView
            self.rightViewMode = .always

        case .both(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            // left
            self.leftView = paddingView
            self.leftViewMode = .always
            // right
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
    
    /// Applies proper semantic content direction, text alignment, and refreshes placeholder for current language direction
    func applyLocaleDirection() {
        let isRTL = Locale.Language(identifier:LanguageManager.shared.currentLanguage).characterDirection == .rightToLeft
        self.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        self.textAlignment = isRTL ? .right : .left
    }
}

extension UITextView {
    /// Applies proper semantic content direction, text alignment, and refreshes placeholder for current language direction
    func applyLocaleDirection() {
        let isRTL = Locale.Language(identifier:LanguageManager.shared.currentLanguage).characterDirection == .rightToLeft
        self.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        self.textAlignment = isRTL ? .right : .left
    }
}
