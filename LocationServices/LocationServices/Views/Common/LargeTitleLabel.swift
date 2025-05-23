//
//  LargeTitleLabel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class LargeTitleLabel: UILabel {
    
    enum Constants {
        static let labelFontSize: CGFloat = 20
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    convenience init(labelText: String) {
        self.init(frame: .zero)
        text = labelText
    }
    
    private func setup() {
        applyLocaleDirection()
        font = .amazonFont(type: .bold, size: Constants.labelFontSize)
        textColor = .lsTetriary
    }
}
