//
//  AddGeofenceBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class AddGeofenceBuilder {
    static func create(activeGeofencesLists: [GeofenceDataModel], isEditingSceneEnabled: Bool, model: GeofenceDataModel?, lat: Double?, long: Double?) -> AddGeofenceVC {
        let vc = AddGeofenceVC(model: model)
        vc.userLocation = (lat, long)
        vc.isEditingSceneEnabled = isEditingSceneEnabled
        let searchService = LocationService()
        let geofenceService = GeofenceAPIService()
        let vm = AddGeofenceViewModel(searchService: searchService,
                                      geofenceService: geofenceService,
                                      activeGeofencesLists: activeGeofencesLists)
        vc.viewModel = vm
        return vc
    }
}
