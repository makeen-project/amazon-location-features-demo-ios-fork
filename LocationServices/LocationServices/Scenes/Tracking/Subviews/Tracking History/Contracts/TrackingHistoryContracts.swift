//
//  TrackingHistoryContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol TrackingHistoryViewModelProtocol : AnyObject  {
    var delegate: TrackingHistoryViewModelOutputDelegate? { get set }
    func loadData() async
    func startTracking(lat: Double, long: Double)
    func getItemCount(for section: Int) -> Int
    func getCellModel(indexPath: IndexPath) -> TrackHistoryCellModel?
    func getTitle(for section: Int) -> String
    func sectionsCount() -> Int
    func setHistory(_ history: [TrackingHistoryPresentation])
    func getTrackingStatus() -> Bool
    func changeTrackingStatus(_ isTrackingActive: Bool)
    func deleteHistory() async throws
}

protocol TrackingHistoryViewModelOutputDelegate: AnyObject, AlertPresentable {
    func reloadTableView()
    func stopTracking()
}
