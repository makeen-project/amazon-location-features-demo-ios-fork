//
//  WebViewVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class WebViewVCBuilder {
    static func create(rawUrl: String) -> WebViewVC {
        let controller = WebViewVC(rawUrl: rawUrl)
        return controller
    }
}
