//
//  Array+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

extension Array {
subscript(safe index: Int) -> Element? {
    guard index < endIndex, index >= startIndex else { return nil}
        return self[index]
    }
}
