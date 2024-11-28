//
//  Locale+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

extension Locale {
    static func currentLanguageIdentifier() -> String {
        return (UserDefaultsHelper.getObject(value: LanguageSwitcherData.self, key: .language)?.value) ?? String(( Locale.preferredLanguages.first ?? Locale.current.identifier).prefix(2))
    }
    
    static func currentLanguageLabel() -> String {
        return (UserDefaultsHelper.getObject(value: LanguageSwitcherData.self, key: .language)?.label) ?? String(( Locale.preferredLanguages.first ?? Locale.current.identifier))
    }
}
