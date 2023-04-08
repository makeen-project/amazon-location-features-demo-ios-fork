//
//  GeofenceDashboardBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class GeofenceDashboardBuilder {
    static func create(lat: Double?, long: Double?, geofences: [GeofenceDataModel]) -> GeofenceDashboardVC {
        let vc = GeofenceDashboardVC()
        vc.userlocation = (lat, long)
        let service = GeofenceAPIService()
        let vm = GeofenceDashboardViewModel(geofenceService: service)
        vm.geofences = geofences
        vc.viewModel = vm
        vc.datas = geofences
        return vc
    }
}
