//
//  UIStackView+Extensions.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension UIStackView {
    func removeArrangedSubViews() {
        arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
}
