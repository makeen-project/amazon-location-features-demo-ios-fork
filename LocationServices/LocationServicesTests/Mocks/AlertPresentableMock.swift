//
//  AlertPresentableMock.swift
//  LocationServicesTests
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
@testable import LocationServices

class AlertPresentableMock: AlertPresentable {
    var showAlertCalled = false
    var alertModel: AlertModel?
    
    func showAlert(_ model: AlertModel) {
        showAlertCalled = true
        alertModel = model
    }
    
    func tapMainActionButton() {
        showAlertCalled = false
        alertModel?.okHandler?()
    }
}
