//
//  VersionVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class VersionVCBuilder {
    static func create() -> VersionVC {
        let controller = VersionVC()
        controller.hidesBottomBarWhenPushed = true
        return controller
    }
}
