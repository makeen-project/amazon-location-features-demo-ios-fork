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
    
    func convertFormattedKMString() -> String {
        let distanceInMeters = Int(convertKMToM())
        return distanceInMeters.convertToKm()
    }
    
    func convertKMToM() -> Double {
        return self * 1000
    }

    func convertToKm() -> String {
        let num: Double = Double(self)
        if num > 1000 {
            let result = Double(num * 1000 / 1000 / 1000)
            return String(format: "%.2f", result) + " km"
        } else {
            return "\(num) m"
        }
    }
}
