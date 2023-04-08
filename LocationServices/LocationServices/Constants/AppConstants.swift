//
//  AppConstants.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class DefaultUserSettings {
    static let mapStyle = MapStyleModel(title: "Light" ,
                                    imageType: .light ,
                                    type: .esri,
                                    isSelected: true)
    static let mapHereStyle = MapStyleModel(title: "Explore" ,
                                        imageType: .explore ,
                                        type: .here,
                                        isSelected: true)
    static let unitValue = "Metric"
}

final class DefaultMapStyles {
   static let mapStyles: [MapStyleModel] =  [
        MapStyleModel(title: "Light" ,
                      imageType: .light ,
                      type: .esri,
                      isSelected: true),
        MapStyleModel(title: "Streets" ,
                      imageType: .street ,
                      type: .esri,
                      isSelected: false),
        MapStyleModel(title: "Navigation" ,
                      imageType: .navigation ,
                      type: .esri,
                      isSelected: false),
        MapStyleModel(title: "Dark Gray" ,
                      imageType: .darkGray ,
                      type: .esri,
                      isSelected: false),
        MapStyleModel(title: "Light Gray" ,
                      imageType: .lightGray ,
                      type: .esri,
                      isSelected: false),
        MapStyleModel(title: "Imagery" ,
                      imageType: .Imagery ,
                      type: .esri,
                      isSelected: false),
        MapStyleModel(title: "Explore" ,
                      imageType: .explore ,
                      type: .here,
                      isSelected: false),
        MapStyleModel(title: "Contrast" ,
                      imageType: .contrast ,
                      type: .here,
                      isSelected: false),
        MapStyleModel(title: "ExploreTruck" ,
                      imageType: .exploreTruck ,
                      type: .here,
                      isSelected: false),
        MapStyleModel(title: "Imagery" ,
                      imageType: .hereImagery ,
                      type: .here,
                      isSelected: false),
        MapStyleModel(title: "Hybrid" ,
                      imageType: .hybrid ,
                      type: .here,
                      isSelected: false),
    ]
}
