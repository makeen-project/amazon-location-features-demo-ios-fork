//
//  Int+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension Int {
    func formatToKmString() -> String {
        let num: Double = Double(self)
        if num > 1000 {
            let result = Double(round(num * 1000 / 1000) / 1000)
            return String(format: "%.2f", result) + " km"
        } else {
            return "\(num) m"
        }
    }
}

extension Int64 {
    func formatToKmString() -> String {
        let num: Double = Double(self)
        if num > 1000 {
            let result = Double(round(num * 1000 / 1000) / 1000)
            return String(format: "%.2f", result) + " km"
        } else {
            return "\(num) m"
        }
    }
}
