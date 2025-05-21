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
    
//    static func currentMapLanguageLabel() -> String {
//        return (UserDefaultsHelper.getObject(value: LanguageSwitcherData.self, key: .mapLanguage)?.label) ?? currentAppLanguageLabel()
//    }
    
    static func currentAppLanguageIdentifier() -> String {
        let appLanguage = UserDefaultsHelper.get(for: [String].self, key: .AppleLanguages)?.first ?? String(( Locale.preferredLanguages.first ?? Locale.current.identifier).prefix(2))
        print("appLanguage: \(appLanguage)")
        return appLanguage
    }
    
//    static func currentAppLanguageLabel() -> String {
//        return (UserDefaultsHelper.getObject(value: LanguageSwitcherData.self, key: .AppleLanguages)?.label) ?? String(( Locale.preferredLanguages.first ?? Locale.current.identifier))
//    }
}
