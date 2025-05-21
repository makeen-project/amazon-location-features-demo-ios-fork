//
//  Locale+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

extension Locale {
    static func currentMapLanguageIdentifier() -> String {
        return UserDefaultsHelper.get(for: String.self, key: .mapLanguage) ?? currentAppLanguageIdentifier()
    }

    static func currentAppLanguageIdentifier() -> String {
        let appLanguage =  String((UserDefaultsHelper.get(for: [String].self, key: .AppleLanguages)?.first)?.prefix(2) ??
                                  (Locale.preferredLanguages.first ?? Locale.current.identifier).prefix(2))
        return appLanguage
    }
}
