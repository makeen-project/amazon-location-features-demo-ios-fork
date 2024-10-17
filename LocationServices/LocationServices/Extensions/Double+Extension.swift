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
        let distanceInMeters = convertKMToMeters()
        return distanceInMeters.formatToKmString()
    }
    
    func convertKMToMeters() -> Double {
        return self * 1000
    }

    func formatToKmString() -> String {
        if self >= 1000 {
            return String(format: "%.2f km", self / 1000)
        } else {
            return String(format: "%.0f m", self)
        }
    }
}
