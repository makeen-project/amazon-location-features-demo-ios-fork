//
//  GridBackgroundView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0


import UIKit

class GridBackgroundView: UIView {
    
    var gridSizeX: CGFloat = 30 // Customize the size of the grid cells
    var gridSizeY: CGFloat = 40 // Customize the size of the grid cells
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor(hex: "#f9f9fb") // Set the background color to gray
        isOpaque = false // Make sure the view is not opaque
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setLineWidth(1) // Customize the line width
        context.setStrokeColor(UIColor(hex: "#E5E5EA").cgColor) // Customize the line color
        
        // Draw the vertical lines
        for x in stride(from: 0, through: rect.width, by: gridSizeX) {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        // Draw the horizontal lines
        for y in stride(from: 0, through: rect.height, by: gridSizeY) {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        context.strokePath()
    }
}
