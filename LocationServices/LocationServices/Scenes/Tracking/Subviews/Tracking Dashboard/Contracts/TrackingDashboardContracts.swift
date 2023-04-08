//
//  TrackingDashboardContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol TrackingDashboardViewModelProcotol: AnyObject {
    var delegate: TrackingDashboardViewModelOutputProtocol? { get set}
    func saveData(state: Bool)

}

protocol TrackingDashboardViewModelOutputProtocol: AnyObject {
    func openHistoryPage()
    func close()
}

