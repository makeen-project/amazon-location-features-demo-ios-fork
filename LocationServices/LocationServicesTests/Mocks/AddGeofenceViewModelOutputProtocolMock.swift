//
//  AddGeofenceViewModelOutputProtocolMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
@testable import LocationServices

class AddGeofenceViewModelOutputProtocolMock: AddGeofenceViewModelOutputProtocol {
    
    var alertMock = AlertPresentableMock()
    
    var finishProcessCalled: Bool = false
    
    var searchResultCalled: Bool = false
    var searchResultMapModel: [MapModel]?
    
    var selectedPlaceResultCalled: Bool = false
    var selectedPlaceResultMapModel: MapModel?
    
    func showAlert(_ model: AlertModel) {
        alertMock.showAlert(model)
    }
    
    func finishProcess() {
        finishProcessCalled = true
    }
    
    func searchResult(mapModel: [MapModel]) {
        searchResultCalled = true
        searchResultMapModel = mapModel
    }
    
    func selectedPlaceResult(mapModel: MapModel) {
        selectedPlaceResultCalled = true
        selectedPlaceResultMapModel = mapModel
    }
}
