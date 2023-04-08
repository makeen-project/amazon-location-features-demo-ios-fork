//
//  Locale+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

extension Locale {
    static func currentLanguageIdentifier() -> String {
        return String((Locale.preferredLanguages.first ?? Locale.current.identifier).prefix(2))
    }
}
