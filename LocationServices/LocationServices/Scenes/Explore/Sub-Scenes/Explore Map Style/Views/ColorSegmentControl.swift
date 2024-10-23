//
//  ColorSegmentControl.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import UIKit

final class ColorSegmentControl: UISegmentedControl {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let colorNames = [MapStyleColorType.light.colorName, MapStyleColorType.dark.colorName]
        
        let lightImage = GeneralHelper.getImageAndText(image: UIImage(systemName: "sun.max")!, string: colorNames[0], isImageBeforeText: true)
        let darkImage = GeneralHelper.getImageAndText(image: UIImage(systemName: "moon")!, string: colorNames[1], isImageBeforeText: true)
        
        self.setImage(lightImage, forSegmentAt: 0)
        self.setImage(darkImage, forSegmentAt: 1)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mapStyleTintColor], for: .selected)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)

        let colorType = UserDefaultsHelper.getObject(value: MapStyleColorType.self, key: .mapStyleColorType)
        self.selectedSegmentIndex = (colorType != nil && colorType! == .dark) ? 1 : 0
        
        self.addTarget(self, action: #selector(mapColorChanged(_:)), for: .valueChanged)
    }
    
    @objc func mapColorChanged(_ sender: UISegmentedControl) {
        let colorType: MapStyleColorType = sender.selectedSegmentIndex == 1 ? .dark : .light
        UserDefaultsHelper.saveObject(value: colorType, key: .mapStyleColorType)
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
    }
}
