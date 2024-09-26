//
//  GeofenceContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol GeofenceNavigationDelegate: AnyObject, AuthActionsHelperDelegate {
    func showLoginFlow()
    func showLoginSuccess()
    func showDashboardFlow(geofences: [GeofenceDataModel], lat: Double?, long: Double?)
    func dismissCurrentScene(geofences: [GeofenceDataModel], shouldDashboardShow: Bool)
    func dismissCurrentBottomSheet(geofences: [GeofenceDataModel], shouldDashboardShow: Bool)
    func showMapStyleScene()
    func showAddGeofenceFlow(activeGeofencesLists: [GeofenceDataModel],
                             isEditingSceneEnabled: Bool,
                             model: GeofenceDataModel?,
                             lat: Double?,
                             long: Double?)
    func showAttribution()
}

protocol GeofenceViewModelProtocol: AnyObject {
    var geofences: [GeofenceDataModel] { get }
    var delegate: GeofenceViewModelDelegate? { get set }
    
    func hasUserLoggedIn() -> Bool
    func getGeofence(with id: String) -> GeofenceDataModel?
    func deleteGeofence(with id: String)
    func addGeofence(model: GeofenceDataModel)
    func fetchListOfGeofences() async
}

protocol GeofenceViewModelDelegate: AnyObject, AlertPresentable {
    func showGeofences(_ models: [GeofenceDataModel])
}
