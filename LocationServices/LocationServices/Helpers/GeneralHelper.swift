//
//  GeneralHelper.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import UIKit
import MapLibre

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
    
    static func setMapLanguage(mapView: MLNMapView, style: MLNStyle) {
        let language = Locale.currentMapLanguageIdentifier()
        
        style.localizeLabels(into: Locale(identifier: language))
        
        style.layers.forEach { layer in
            guard let symbolLayer = layer as? MLNSymbolStyleLayer,
                  let textExpression = symbolLayer.text else { return }
            let exp = "\(String(describing: symbolLayer.text))"
            if exp.contains("MLN_IF(") {
                return
            }
            let mglExpression = textExpression.mgl_jsonExpressionObject
            let expression = recurseExpression(exp: mglExpression, prevPropertyRegex: "^name:([A-Za-z\\-_]+)$", nextProperty: "name:\(language)", language: language)
            symbolLayer.text = NSExpression(mglJSONObject: expression)
        }
    }
    
    static func recurseExpression(exp: Any, prevPropertyRegex: String, nextProperty: String, language: String) -> Any {
        if let arrayExp = exp as? [Any] {
            guard arrayExp.first as? String == "coalesce" else {
                return arrayExp.map { recurseExpression(exp: $0, prevPropertyRegex: prevPropertyRegex, nextProperty: nextProperty, language: language) }
            }
            
            guard arrayExp.count > 2,
                  let first = arrayExp[1] as? [Any], first.first as? String == "get",
                  let firstProperty = first.last as? String,
                  let _ = firstProperty.range(of: prevPropertyRegex, options: .regularExpression),
                  let second = arrayExp[2] as? [Any], second.first as? String == "get" else {
                return arrayExp.map { recurseExpression(exp: $0, prevPropertyRegex: prevPropertyRegex, nextProperty: nextProperty, language: language) }
            }
            
            if language == "zh-Hant" {
                // Special handling for zh-Hant
                return [
                    "coalesce",
                    ["get", "name:zh-Hant"],
                    ["get", "name:zh"],
                    ["get", "name:en"],
                    ["get", "name"]
                ]
            }
            else {
                return [
                    "coalesce",
                    ["get", nextProperty],
                    ["get", "name:en"],
                    ["get", "name"]
                ]
            }
        }
        
        return exp
    }
    
    static func setupValidAWSConfiguration() async throws {
        guard let configurationModel = GeneralHelper.getAWSConfigurationModel() else {
            print("Can't read default configuration from awsconfiguration.json")
            return
        }
        try await GeneralHelper.initializeMobileClient(configurationModel: configurationModel)
    }
    
    static func getAWSConfigurationModel() -> CustomConnectionModel? {
        var defaultConfiguration: CustomConnectionModel? = nil
        // default configuration
        if let identityPoolIds = (Bundle.main.object(forInfoDictionaryKey: "IdentityPoolIds") as? String)?.components(separatedBy: ","),
           let regions = (Bundle.main.object(forInfoDictionaryKey: "AWSRegions") as? String)?.components(separatedBy: ","),
           let apiKeys = (Bundle.main.object(forInfoDictionaryKey: "ApiKeys") as? String)?.components(separatedBy: ","),
           let webSocketUrls = (Bundle.main.object(forInfoDictionaryKey: "WebSocketUrls") as? String)?.components(separatedBy: ",") {
            
                if let region = RegionSelector.shared.getCachedRegion(),
                   let regionIndex = regions.firstIndex(of: region) {
                    let identityPoolId = identityPoolIds[regionIndex]
                    let apiKey = apiKeys[regionIndex]
                    let webSocketUrl = webSocketUrls[regionIndex]
                    
                    defaultConfiguration = CustomConnectionModel(identityPoolId: identityPoolId, webSocketUrl: webSocketUrl, apiKey: apiKey, region: region)
                }
        }
        return defaultConfiguration
    }
    
    private static func initializeMobileClient(configurationModel: CustomConnectionModel) async throws {
        try await CognitoAuthHelper.initialise(identityPoolId: configurationModel.identityPoolId)
        try await ApiAuthHelper.initialise(apiKey: configurationModel.apiKey, region: configurationModel.region)
    }
    
    static func getAppIcon() -> UIImage? {
        if let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcons = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcons["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
    
}


struct CustomConnectionModel: Codable {
    var identityPoolId: String
    var webSocketUrl: String
    var apiKey: String
    var region: String
}
