//
//  AttributionVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class AttributionVCBuilder {
    static func create(withNavBar: Bool = false) -> AttributionVC {
        let controller = AttributionVC(navBarNeeded: withNavBar)
        return controller
    }
}
