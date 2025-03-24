//
//  TrackingContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation

protocol TrackingNavigationDelegate: AnyObject, AuthActionsHelperDelegate {
    func showNextTrackingScene()
    func showTrackingHistory(isTrackingActive: Bool)
    func showMapStyleScene()
    func showLoginFlow()
    func showLoginSuccess()
    func showAttribution()
    func showDashboardFlow()
}

protocol TrackingViewModelProtocol: AnyObject {
    var delegate: TrackingViewModelDelegate? { get set }
    var busRoutes: [BusRoute] { get set }
    
    func startIoTSubscription()
    func stopIoTSubscription()
    func fetchListOfGeofences(collectionName: String) async -> [GeofenceDataModel]?
    func showGeofences(routeId: String, geofences: [GeofenceDataModel])
    func drawTrackingRoute(routeId: String, coordinates: [CLLocationCoordinate2D])
    func evaluateGeofence(coordinate: CLLocationCoordinate2D, collectionName: String) async
}

protocol TrackingViewModelDelegate: AnyObject, AlertPresentable {
    func drawTrackingRoute(routeId: String, coordinates: [CLLocationCoordinate2D])
    func showGeofences(routeId: String, _ models: [GeofenceDataModel])
}
