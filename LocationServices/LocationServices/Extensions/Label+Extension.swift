//
//  UILabel+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension UILabel {
    /// Applies proper semantic content direction, text alignment, and refreshes placeholder for current language direction
    func applyLocaleDirection() {
        let isRTL = Locale.Language(identifier:LanguageManager.shared.currentLanguage).characterDirection == .rightToLeft
        self.semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        self.textAlignment = isRTL ? .right : .left
    }
}
