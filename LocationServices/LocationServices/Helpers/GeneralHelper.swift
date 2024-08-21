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
        case .darkGray,
             .Imagery,
             .hereImagery,
             .hybrid:
            return UIColor.white
        case .light,
             .street,
             .navigation,
             .explore,
             .contrast,
             .exploreTruck,
             .lightGray:
            return UIColor.black
        default:
            return UIColor.black
        }
    }
}
