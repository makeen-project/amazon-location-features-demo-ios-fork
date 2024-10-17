//
//  GeneralHelper.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import UIKit

class GeneralHelper {
    static func getAmazonMapLogo() -> UIColor {
        let mapColor = UserDefaultsHelper.getObject(value: MapStyleColorType.self, key: .mapStyleColorType)
        let mapStyle = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        if mapStyle?.imageType == .hybrid || mapStyle?.imageType == .satellite {
            return UIColor.white
        }
        else {
            switch mapColor {
            case .dark:
                return UIColor.white
            case .light:
                return UIColor.black
            default:
                return UIColor.black
            }
        }
    }
    
    static func getImageAndText(image: UIImage,
                             string: String,
                             isImageBeforeText: Bool,
                             segFont: UIFont? = nil) -> UIImage {
        let font = segFont ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        let expectedTextSize = (string as NSString).size(withAttributes: [.font: font])
        let width = expectedTextSize.width + image.size.width + 5
        let height = max(expectedTextSize.height, image.size.width)
        let size = CGSize(width: width, height: height)

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let fontTopPosition: CGFloat = (height - expectedTextSize.height) / 2
            let textOrigin: CGFloat = isImageBeforeText
                ? image.size.width + 5
                : 0
            let textPoint: CGPoint = CGPoint.init(x: textOrigin, y: fontTopPosition)
            string.draw(at: textPoint, withAttributes: [.font: font])
            let alignment: CGFloat = isImageBeforeText
                ? 0
                : expectedTextSize.width + 5
            let rect = CGRect(x: alignment,
                              y: (height - image.size.height) / 2,
                              width: image.size.width,
                              height: image.size.height)
            image.withRenderingMode(.alwaysTemplate).draw(in: rect)
        }
    }
}
