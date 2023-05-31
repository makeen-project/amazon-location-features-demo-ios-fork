//
//  AttributionVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class AttributionVCBuilder {
    static func create() -> AttributionVC {
        let controller = AttributionVC()
        controller.hidesBottomBarWhenPushed = true
        return controller
    }
}
