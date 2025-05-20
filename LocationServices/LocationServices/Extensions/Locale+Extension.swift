//
//  Locale+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

extension Locale {
    static func currentMapLanguageIdentifier() -> String {
        return (UserDefaultsHelper.getObject(value: LanguageSwitcherData.self, key: .mapLanguage)?.value) ?? currentAppLanguageIdentifier()
    }
    
    static func currentMapLanguageLabel() -> String {
        return (UserDefaultsHelper.getObject(value: LanguageSwitcherData.self, key: .mapLanguage)?.label) ?? currentAppLanguageLabel()
    }
    
    static func currentAppLanguageIdentifier() -> String {
        return (UserDefaultsHelper.getObject(value: LanguageSwitcherData.self, key: .AppleLanguages)?.value) ?? String(( Locale.preferredLanguages.first ?? Locale.current.identifier).prefix(2))
    }
    
    static func currentAppLanguageLabel() -> String {
        return (UserDefaultsHelper.getObject(value: LanguageSwitcherData.self, key: .AppleLanguages)?.label) ?? String(( Locale.preferredLanguages.first ?? Locale.current.identifier))
    }
}
