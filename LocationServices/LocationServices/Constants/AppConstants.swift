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
    static let mapHereStyle = MapStyleModel(title: "Standard Light" ,
                                        imageType: .light ,
                                        type: .here,
                                        isSelected: true)
    static let unitValue = "Metric"
}

final class BaseAPIEndpoint {
    static func baseUrl(apiKey: String, region: String, apiName: String) -> String {
        return "https://\(apiName).geo.\(region).amazonaws.com/v2?key=\(apiKey)"
    }
}

final class DefaultMapStyles {
   static let mapStyles: [MapStyleModel] =  [
        MapStyleModel(title: "Standard Light" ,
                      imageType: .light ,
                      type: .esri,
                      isSelected: true),
        MapStyleModel(title: "Standard Dark" ,
                      imageType: .dark ,
                      type: .esri,
                      isSelected: false),
        MapStyleModel(title: "Visualization Light" ,
                      imageType: .vlight,
                      type: .esri,
                      isSelected: false),
        MapStyleModel(title: "Visualization Dark" ,
                      imageType: .vdark,
                      type: .esri,
                      isSelected: false),
        MapStyleModel(title: "Logistics Light" ,
                      imageType: .llight ,
                      type: .esri,
                      isSelected: false),
        MapStyleModel(title: "Logistics Dark" ,
                      imageType: .ldark ,
                      type: .esri,
                      isSelected: false),
        MapStyleModel(title: "Hybrid" ,
                      imageType: .hybrid ,
                      type: .esri,
                      isSelected: false),
        MapStyleModel(title: "Satellite" ,
                      imageType: .satellite,
                      type: .esri,
                      isSelected: false),
    ]
}
