//
//  Locale+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

extension Locale {
    static func currentMapLanguageIdentifier() -> String {
        return UserDefaultsHelper.get(for: String.self, key: .mapLanguage) ?? "en"
    }

    static func currentAppLanguageIdentifier() -> String {
        var appLanguage =  String((UserDefaultsHelper.get(for: [String].self, key: .AppleLanguages)?.first) ??
                                  (Locale.preferredLanguages.first ?? Locale.current.identifier))
        if !(appLanguage.contains("pt-") || appLanguage.contains("zh-") || appLanguage.contains("zh-")) {
            appLanguage = appLanguage.prefix(2).lowercased()
        }
        return appLanguage
    }
}
