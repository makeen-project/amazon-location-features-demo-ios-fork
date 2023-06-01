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
    var isTrackingActive: Bool { get }
    var hasHistory: Bool { get }
    
    func startTracking()
    func stopTracking()
    func trackLocationUpdate(location: CLLocation?)
    func fetchListOfGeofences()
    func updateHistory()
    func resetHistory()
}

protocol TrackingViewModelDelegate: AnyObject, AlertPresentable {
    func drawTrack(history: [TrackingHistoryPresentation])
    func historyLoaded()
    func showGeofences(_ models: [GeofenceDataModel])
}
