//
//  LocationServicesCustomFonts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

enum LocationServiceCustomFontType: String {
    case regular = "AmazonEmber-Regular"
    case medium = "AmazonEmber-Medium"
    case bold = "AmazonEmber-Bold"
}

extension UIFont {
    static func amazonFont(type: LocationServiceCustomFontType, size: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: type.rawValue, size: size) else {
            fatalError("Found Coulnd't loaded.")
        }
        return customFont
    }
}
