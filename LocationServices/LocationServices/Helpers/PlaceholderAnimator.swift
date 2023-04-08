//
//  PlaceholderAnimator.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

class PlaceholderAnimator {
    
    private let dataViews: [UIView]
    private let placeholderViews: [UIView]
    
    private var isActiveAnimation = false
    private var timer: Timer?
    
    init(dataViews: [UIView], placeholderViews: [UIView]) {
        self.dataViews = dataViews
        self.placeholderViews = placeholderViews
    }
    
    func setupAnimationStatus(isActive: Bool) {
        isActiveAnimation = isActive
        
        changeVisibility(!isActive, for: dataViews)
        changeVisibility(isActive, for: placeholderViews)
        
        if isActiveAnimation {
            startAnimating()
        }
    }
    
    private func startAnimating() {
        UIView.animate(withDuration: 1, animations: { [weak self] in
            let isVisible = self?.placeholderViews.first?.alpha == 1
            let nextAlphaValue: CGFloat = isVisible ? 0 : 1
            self?.placeholderViews.forEach { $0.alpha = nextAlphaValue }
        }, completion: { [weak self] _ in
            guard let self, self.isActiveAnimation else { return }
            self.startAnimating()
        })
    }
    
    private func changeVisibility(_ isVisible: Bool, for views: [UIView]) {
        views.forEach { $0.isHidden = !isVisible }
    }
}
