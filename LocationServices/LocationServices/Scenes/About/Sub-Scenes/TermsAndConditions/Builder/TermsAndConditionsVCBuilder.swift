//
//  TermsAndConditionsVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class TermsAndConditionsVCBuilder {
    static func create() -> TermsAndConditionsVC {
        let controller = TermsAndConditionsVC()
        controller.hidesBottomBarWhenPushed = true
        return controller
    }
}
