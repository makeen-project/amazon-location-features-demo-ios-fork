//
//  Int+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension Int {
    private static let durationFormatter: DateComponentsFormatter = {
        let calendar = Calendar(identifier: .gregorian)
        var componentsCalendar = calendar
        componentsCalendar.locale = Locale(identifier: LanguageManager.shared.currentLanguage)

        let formatter = DateComponentsFormatter()
        formatter.calendar = componentsCalendar
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }()
    
    func formatDistance(decimalPoints: Int = 2) -> String {
        let num = Double(self)
        return num.formatDistance(decimalPoints: decimalPoints)
    }

    func convertSecondsToMinString() -> String {
        Self.durationFormatter.calendar?.locale = Locale(identifier: LanguageManager.shared.currentLanguage)
        if let formattedString = Self.durationFormatter.string(from: Double(self)) {
            return formattedString
        } else {
            let min = Int(self / 60)
            return "\(min) \(StringConstant.min)"
        }
    }
}

extension Int64 {
    func formatDistance(decimalPoints: Int = 2) -> String {
        let num = Double(self)
        return num.formatDistance(decimalPoints: decimalPoints)
    }
}
