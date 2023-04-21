//
//  GeofenceViewModelDelegateMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
@testable import LocationServices

class GeofenceViewModelDelegateMock: GeofenceViewModelDelegate {
    
    var alertMock = AlertPresentableMock()
    
    var showGeofencesCalled = false
    var models: [GeofenceDataModel]?
    
    func showAlert(_ model: LocationServices.AlertModel) {
        alertMock.showAlert(model)
    }

    func showGeofences(_ models: [GeofenceDataModel]) {
        showGeofencesCalled = true
        self.models = models
    }
}
