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
        let colorNames = [MapStyleColorType.light.colorLabel, MapStyleColorType.dark.colorLabel]
        
        let lightImage = GeneralHelper.getImageAndText(image: UIImage(systemName: "sun.max")!, string: colorNames[0], isImageBeforeText: true)
        let darkImage = GeneralHelper.getImageAndText(image: UIImage(systemName: "moon")!, string: colorNames[1], isImageBeforeText: true)
        
        self.setImage(lightImage, forSegmentAt: 0)
        self.setImage(darkImage, forSegmentAt: 1)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.mapStyleTintColor], for: .selected)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        
        let colorType = UserDefaultsHelper.getObject(value: MapStyleColorType.self, key: .mapStyleColorType)
        self.selectedSegmentIndex = (colorType != nil && colorType! == .dark) ? 1 : 0
        
        self.addTarget(self, action: #selector(mapColorChanged(_:)), for: .valueChanged)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(validateMapColor(_:)), name: Notification.validateMapColor, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeNotificationObservers(_:)), name: Notification.removeNotificationObservers, object: nil)
        validateMapColor()
    }
    
    @objc func removeNotificationObservers(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func validateMapColor(_ notification: Notification) {
        validateMapColor()
    }
    
    private func validateMapColor() {
        let mapStyle = UserDefaultsHelper.getObject(value: MapStyleModel.self, key: .mapStyle)
        if mapStyle?.imageType == .hybrid || mapStyle?.imageType == .satellite {
            self.isEnabled = false
            self.selectedSegmentIndex = 0
            UserDefaultsHelper.saveObject(value: MapStyleColorType.light, key: .mapStyleColorType)
        }
        else {
            self.isEnabled = true
        }
    }
    
    @objc func mapColorChanged(_ sender: UISegmentedControl) {
        let colorType: MapStyleColorType = sender.selectedSegmentIndex == 1 ? .dark : .light
        UserDefaultsHelper.saveObject(value: colorType, key: .mapStyleColorType)
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
    }
}
