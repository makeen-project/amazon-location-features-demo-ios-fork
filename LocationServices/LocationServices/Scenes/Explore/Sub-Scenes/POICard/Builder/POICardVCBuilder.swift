//
//  POICardVCBuilder.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import CoreLocation

final class POICardVCBuilder {
    static func create(cardData: [MapModel], lat: Double?, long: Double?) -> POICardVC {
        let vc = POICardVC()
        let routingService = RoutingAPIService()
        
        var userLocation: CLLocationCoordinate2D? = nil
        if let lat, let long {
            userLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        let vm = POICardViewModel(routingService: routingService, datas: cardData, userLocation: userLocation)
        vc.viewModel = vm
        return vc
    }
}
