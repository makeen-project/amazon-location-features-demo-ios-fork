//
//  TrackingSimulationViewModelProtocol.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol TrackingSimulationViewModelProtocol : AnyObject  {
    var delegate: TrackingSimulationViewModelOutputDelegate? { get set }
    func loadData() async
    func startTracking(lat: Double, long: Double)
    func getItemCount(for section: Int) -> Int
    func getTitle(for section: Int) -> String
    func sectionsCount() -> Int
    func getTrackingStatus() -> Bool
    func changeTrackingStatus(_ isTrackingActive: Bool)
}

protocol TrackingSimulationViewModelOutputDelegate: AnyObject, AlertPresentable {
    func reloadTableView()
    func stopTracking()
}
