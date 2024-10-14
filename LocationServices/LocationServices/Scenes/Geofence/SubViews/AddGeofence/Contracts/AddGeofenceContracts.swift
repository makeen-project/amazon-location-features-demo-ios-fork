//
//  AddGeofenceContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

protocol AddGeofenceViewModelProcotol: AnyObject {
    var delegate: AddGeofenceViewModelOutputProtocol? { get set}
    var activeGeofencesLists: [GeofenceDataModel] { get }
    
    func isGeofenceNameValid(_ name: String?) -> Bool
    func isGeofenceModelValid(_ model: GeofenceDataModel) -> Bool
    func saveData(with id: String, lat: Double, long: Double, radius: Double) async throws -> Result<GeofenceDataModel, Error>
    func deleteData(with model: GeofenceDataModel)
    func searchWith(text: String, userLat: Double?, userLong: Double?) async throws
    func searchWithSuggestion(text: String, userLat: Double?, userLong: Double?) async throws
    func searchSelectedPlaceWith(_ indexPath: IndexPath, lat: Double?, long: Double?) async throws -> Bool
    func numberOfRowsInSection() -> Int
    func getSearchCellModel() -> [SearchCellViewModel]
}

protocol AddGeofenceViewModelOutputProtocol: AnyObject, AlertPresentable {
    func finishProcess()
    func searchResult(mapModel: [MapModel])
    func selectedPlaceResult(mapModel: MapModel)
}

