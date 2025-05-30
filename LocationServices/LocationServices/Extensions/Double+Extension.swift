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
            return "\(min) \(StringConstant.min)"
        }
    }
    
    func formatDistance(decimalPoints: Int = 2) -> String {
        let unitType = UnitHelper.getResolvedUnit()
        let num = Double(self)
        let factor = pow(10.0, Double(decimalPoints))
        
        if unitType == .metric {
            let result = (num / 1000 * factor).rounded() / factor // Convert meters to km and round
            return String(format: "%.\(decimalPoints)f \(StringConstant.km)", result)
        } else {
            let numMiles = (convertMetersToMiles(meters: num) * factor).rounded() / factor
            return String(format: "%.\(decimalPoints)f \(StringConstant.mi)", numMiles)
        }
    }

    private func convertMetersToMiles(meters: Double) -> Double {
        return meters * 0.00062137
    }
}
