//
//  Int+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension Int {
    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        formatter.allowedUnits = [.day, .hour, .minute]
        
        return formatter
    }()
    
    func formatDistance() -> String {
        let num = Double(self)
        return num.formatDistance()
    }

    func convertSecondsToMinString() -> String {
        if let formattedString = Self.durationFormatter.string(from: Double(self)) {
            return formattedString
        } else {
            let min = Int(self / 60)
            return "\(min) min"
        }
    }
}

extension Int64 {
    func formatDistance() -> String {
        let num = Double(self)
        return num.formatDistance()
    }
}
