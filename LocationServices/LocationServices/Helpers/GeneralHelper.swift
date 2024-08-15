//
//  GeneralHelper.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import UIKit

class GeneralHelper {
    static func getAmazonMapLogo(mapImageType: MapStyleImages?) -> UIColor {
        switch mapImageType {
        case .dark, .vdark, .ldark, .satellite, .hybrid:
            return UIColor.white
        case .light, .llight, .vlight:
            return UIColor.black
        default:
            return UIColor.black
        }
    }
}
