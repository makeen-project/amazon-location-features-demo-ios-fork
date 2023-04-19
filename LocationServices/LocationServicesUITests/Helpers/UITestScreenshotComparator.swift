//
//  UITestScreenshotComparator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

struct UITestScreenshotComparator {
    
    private let allowedDifference: Double
    
    init(allowedDifference: Double = 0) {
        self.allowedDifference = allowedDifference
    }
    
    func areEqual(originalImage: UIImage, changedImage: UIImage) -> Bool {
        let differencePercentage = findDifference(originalImage: originalImage, changedImage: changedImage)
        return differencePercentage <= allowedDifference
    }
    
    private func findDifference(originalImage: UIImage, changedImage: UIImage) -> Double {
        let width = Int(originalImage.size.width)
        let height = Int(originalImage.size.height)
        guard originalImage.size == changedImage.size,
              let cfData1 = originalImage.cgImage?.dataProvider?.data,
              let l = CFDataGetBytePtr(cfData1),
              let cfData2 = changedImage.cgImage?.dataProvider?.data,
              let r = CFDataGetBytePtr(cfData2) else { return 0 }

        let bytesPerpixel = 4
        let firstPixel = 0
        let lastPixel = (width * height - 1) * bytesPerpixel
        let range = stride(from: firstPixel, through: lastPixel, by: bytesPerpixel)
        
        var countOfIncorrectPixels: Double = 0
        for pixelAddress in range {
            if l.advanced(by: pixelAddress).pointee != r.advanced(by: pixelAddress).pointee ||     //Red
                l.advanced(by: pixelAddress + 1).pointee != r.advanced(by: pixelAddress + 1).pointee || //Green
                l.advanced(by: pixelAddress + 2).pointee != r.advanced(by: pixelAddress + 2).pointee || //Blue
                l.advanced(by: pixelAddress + 3).pointee != r.advanced(by: pixelAddress + 3).pointee  {  //Alpha
                countOfIncorrectPixels += 1
            }
        }
        
        let countOfPixels = Double(width * height - 1)
        return countOfIncorrectPixels / countOfPixels
    }
}
