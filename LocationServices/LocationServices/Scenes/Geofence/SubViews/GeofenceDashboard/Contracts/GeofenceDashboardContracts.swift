//
//  GeofenceDashboardContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol GeofenceDasboardViewModelProtocol: AnyObject {
    var delegate: GeofenceDasboardViewModelOutputProtocol? { get set }
    var geofences: [GeofenceDataModel] { get set }
    
    func fetchListOfGeofences() async
    func deleteGeofenceData(model: GeofenceDataModel)
}

protocol GeofenceDasboardViewModelOutputProtocol: AnyObject, AlertPresentable {
    func refreshData(with model: [GeofenceDataModel])
}
