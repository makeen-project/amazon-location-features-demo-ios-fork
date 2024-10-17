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
}
