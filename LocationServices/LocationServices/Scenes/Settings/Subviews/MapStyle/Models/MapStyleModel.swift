//
//  MapStyleModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

struct MapStyleModel: Codable {
    var title: String
    var imageType: MapStyleImages
    var isSelected: Bool
}
