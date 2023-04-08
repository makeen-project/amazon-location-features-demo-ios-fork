//
//  AmazonLocationLabel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class AmazonLocationLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    convenience init( labelText: String,
                      font: UIFont,
                      isMultiline: Bool = false,
                      fontColor: UIColor? = .black,
                      textAlignment: NSTextAlignment) {
        self.init(frame: .zero)
        
        setupProperties( labelText: labelText,
                         font: font,
                         isMultiline: isMultiline,
                         fontColor: fontColor,
                         textAlignment: textAlignment)
    }
    
    private func setupProperties( labelText: String,
                                  font: UIFont,
                                  isMultiline: Bool = false,
                                  fontColor: UIColor? = .black,
                                  textAlignment: NSTextAlignment
    ) {
        self.text = labelText
        self.font = font
        self.textAlignment = textAlignment
        if isMultiline {
            self.numberOfLines = 0
        }
        self.textColor = fontColor
    }
}
