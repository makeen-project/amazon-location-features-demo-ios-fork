//
//  String+Extensions.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension String {
    
//    func toRegionType() -> AWSRegionType {
//        // by default
//        var region: AWSRegionType = .USEast1
//        // extract region from identity pool
//        
//        if let stringRegion = self.components(separatedBy: ":").first {
//            
//            if let extractedRegion = AWSEndpoint.regionTypeByString(regionString: stringRegion) {
//                region = extractedRegion
//            } else {
//                // regionString is not a valid region
//                print("Invalid region: \(stringRegion)")
//            }
//        }
//        
//        return region
//    }
    
    func toRegionString() -> String {
        return components(separatedBy: ":").first ?? self
    }
    
    func toId() -> String {
        return components(separatedBy: ":").last ?? self
    }
    
    func convertInitalTextImage() -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        let nameInitalLabel = UILabel(frame: frame)
        nameInitalLabel.textAlignment = .center
        nameInitalLabel.backgroundColor = .orange
        nameInitalLabel.textColor = .white
        nameInitalLabel.font = UIFont.boldSystemFont(ofSize: 13)
        nameInitalLabel.text = self
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameInitalLabel.layer.render(in: currentContext)
            let nameInitialImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameInitialImage
        }
        return nil
    }
    /// This Function Create 2 Letter Initial from String itself
    
    func createInitial() -> String? {
        return self.components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.first!)") + "\($1.first!)" }
    }
    
    func convertTextToCoordinate() -> [Double] {
        let splitText = self.split(separator: ",", maxSplits: 1).map(String.init)
        guard let first = Double(splitText[0]), let secondElement = Double(splitText[1].trimmingCharacters(in: .whitespaces)) else { return [] }
        
        var resultAr: [Double] = []
        resultAr.append(secondElement)
        resultAr.append(first)
        
        return resultAr
    }
    
    func formatAddressField() -> [String] {
        let splitText = self.split(separator: ",", maxSplits: 1).map(String.init)
        guard let first = splitText[safe: 0],
              let secondElement = splitText[safe: 1] else { return [] }
        
        var resultAr: [String] = []
        
        resultAr.append(first)
        resultAr.append(secondElement.trimmingCharacters(in: .whitespaces))
        return resultAr
    }
    
    func isCoordinate() -> Bool {
        let regularExpression = #"""
^(-?\d+(\.\d+)?),\s*(-?\d+(\.\d+)?)$
"""#
        guard let regex = try? NSRegularExpression(pattern: regularExpression) else {
               return false
           }
           return regex.firstMatch(in: self, range: NSRange(self.startIndex..., in: self)) != nil
    }
}

extension NSMutableAttributedString {

    public func highlightAsLink(textOccurances: String) -> Bool {
        let foundRange = self.mutableString.range(of: textOccurances)
        guard foundRange.location != NSNotFound else { return false }
        
        self.addAttribute(.foregroundColor, value: UIColor.lsPrimary, range: foundRange)
        return true
    }
}
