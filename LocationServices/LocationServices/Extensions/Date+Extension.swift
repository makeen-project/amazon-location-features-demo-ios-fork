//
//  Date+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

extension Date {
    private static let dateFormatter = DateFormatter()
    private static let relativeDateFormatter = {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .none
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.locale = .current
        relativeDateFormatter.doesRelativeDateFormatting = true
        return relativeDateFormatter
    }()
    
    static func convertStringToDate(_ dateString: String) -> Date? {
        let format = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        if dateFormatter.dateFormat != format {
            dateFormatter.dateFormat = format
        }
        
        return dateFormatter.date(from: dateString)
    }
    
    func convertTimeString() -> String {
        return convertToString(format: "h:mm a")
    }
    
    func convertDateString() -> String {
        return convertToString(format: "MMM d, yyyy")
    }
    
    func convertToString(format: String) -> String {
        let dateFormatter = Self.dateFormatter
        if dateFormatter.dateFormat != format {
            dateFormatter.dateFormat = format
        }
        
        return dateFormatter.string(from: self)
    }
    
    func convertToRelativeString() -> String {
        let dateFormatter = Self.relativeDateFormatter
        return dateFormatter.string(from: self)
    }
    
    func truncateTime() -> Date {
        let format = "dd-MM-yyyy"
        let dateFormatter = Self.dateFormatter
        if dateFormatter.dateFormat != format {
            dateFormatter.dateFormat = format
        }
        
        let truncatedString = dateFormatter.string(from: self)
        let truncatedDate = dateFormatter.date(from: truncatedString)
        
        return truncatedDate ?? self
    }
}
