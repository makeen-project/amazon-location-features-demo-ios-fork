//
//  AmazonLocationButton.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class AmazonLocationButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(title: String) {
        self.init(type: .system)
        setupPropertiesWith(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupPropertiesWith(title: String) {
        self.backgroundColor = .tabBarTintColor
        self.contentMode = .scaleAspectFit
        self.layer.cornerRadius = 10
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = .amazonFont(type: .bold, size: 16)
    }
    
    func changeButton(state: Bool) {
        self.isEnabled = !state
        self.alpha = !state ? 1 : 0.5
    }
}
