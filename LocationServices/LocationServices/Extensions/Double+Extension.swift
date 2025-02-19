//
//  Double+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension Double {
    
    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        formatter.allowedUnits = [.day, .hour, .minute]
        
        return formatter
    }()
    
    func convertSecondsToMinString() -> String {
        if let formattedString = Self.durationFormatter.string(from: self) {
            return formattedString
        } else {
            let min = Int(self / 60)
            return "\(min) min"
        }
    }
    
    func formatDistance() -> String {
        let unitType = UnitHelper.getResolvedUnit()
        let num = Double(self)
        if unitType == .metric {
            if num > 1000 {
                let result = num * 1000 / 1000000 // Convert meters to km
                return String(format: "%.2f km", result)
            } else {
                return String(format: "%.0f m", num)
            }
        } else {
            let numMiles = convertMetersToImperial(meters: num)
            return String(format: "%.2f mi", numMiles)
        }
    }

    func convertMetersToImperial(meters: Double) -> Double {
        let miles = meters / 1609
        return miles
    }
}
