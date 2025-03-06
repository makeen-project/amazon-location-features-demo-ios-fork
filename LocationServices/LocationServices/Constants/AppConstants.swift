//
//  AppConstants.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class DefaultUserSettings {
    static let mapStyle = MapStyleModel(title: "Standard" ,
                                        imageType: .standard,
                                        isSelected: true)
    static let mapStyleColorType = MapStyleColorType.light
    static let unitValue = UnitTypes.automatic
}

final class DefaultMapStyles {
    
    static func getMapStyleUrl() -> URL? {
        if let apiKey = AmazonLocationClient.getApiKey(), let regionName = AmazonLocationClient.getApiKeyRegion() {
            var colorType = UserDefaultsHelper.getObject(value: MapStyleColorType.self, key: .mapStyleColorType) ?? MapStyleColorType.light
            let style = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle) ?? mapStyles.first!
            if style.imageType == .hybrid || style.imageType == .satellite {
                colorType = .light
            }
            
            let politicalView = UserDefaultsHelper.getObject(value: PoliticalViewType.self, key: .politicalView)
            let urlString = "https://maps.geo.\(regionName).amazonaws.com/v2/styles/\(style.title)/descriptor?key=\(apiKey)&color-scheme=\(colorType.colorName)\(politicalView != nil ? "&political-view=\(politicalView!.countryCode)" : "")"
            
            return URL(string: urlString)
        }
        else {
            return nil
        }
    }
    
   static let mapStyles: [MapStyleModel] =  [
        MapStyleModel(title: "Standard" ,
                      imageType: .standard ,
                      isSelected: true),
        MapStyleModel(title: "Monochrome" ,
                      imageType: .monochrome ,
                      isSelected: false),
        MapStyleModel(title: "Hybrid" ,
                      imageType: .hybrid ,
                      isSelected: false),
        MapStyleModel(title: "Satellite" ,
                      imageType: .satellite ,
                      isSelected: false),
    ]
}

enum AppConstants {
    static let amazonHqMapPosition = (latitude: 47.61506909519956, longitude: -122.33826750882835)
}
