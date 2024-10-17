//
//  SearchVCContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol SearchVCProtocol: AnyObject {
    var delegate: SearchVCOutputDelegate? { get set }
    func sendUserLocation(lat: Double?, long: Double?)
}

protocol SearchVCOutputDelegate: AnyObject {
    func shareSearchData(with model: SearchPresentation)
}

protocol SearchViewModelProcotol: AnyObject {
    var delegate: SearchViewModelOutputDelegate? { get set }
    func searchWithSuggestion(text: String, userLat: Double?, userLong: Double?) async throws
    func searchWith(text: String, userLat: Double?, userLong: Double?) async throws
    func numberOfRowsInSection() -> Int
    func getSearchCellModel() -> [SearchCellViewModel]
}

protocol SearchViewModelOutputDelegate: AnyObject, AlertPresentable {
    func searchResult(mapModel: [MapModel], shouldDismiss: Bool, showOnMap: Bool)
    func selectedPlaceResult(mapModel: MapModel)
}
