//
//  ArrivalCardViewModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation

final class ArrivalCardViewModel: ArrivalCardViewModelProcotol {
    
    var route: RouteModel
    
    var delegate: ArrivalCardViewModelOutputDelegate?
    
    init(route: RouteModel) {
        self.route = route
    }
}

