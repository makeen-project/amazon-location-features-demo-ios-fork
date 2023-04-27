//
//  MapBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class MapBuilder {
    static func create() -> MapVC {
        let vc = MapVC()
        let vm = MapViewModel()
        vc.viewModel = vm
        return vc
    }
}
