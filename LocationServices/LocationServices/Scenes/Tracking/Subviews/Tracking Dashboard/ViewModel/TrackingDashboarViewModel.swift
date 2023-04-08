//
//  TrackingDashboarViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

final class TrackingDashboarViewModel: TrackingDashboardViewModelProcotol {
   
    var delegate: TrackingDashboardViewModelOutputProtocol?
 
    
    func saveData(state: Bool) {
        if state {
            delegate?.openHistoryPage()
        } else {
            delegate?.close()
        }
    }
}
