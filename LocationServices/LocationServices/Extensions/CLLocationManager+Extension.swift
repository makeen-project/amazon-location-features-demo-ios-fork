//
//  CLLocationManager+Extension.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation

extension CLLocationManager: CLLocationManagerProtocol {}

protocol CLLocationManagerProtocol: AnyObject {
    var delegate: CLLocationManagerDelegate? { get set }
    var authorizationStatus: CLAuthorizationStatus { get }
    
    func startUpdatingLocation()
    func startUpdatingHeading()
    func requestWhenInUseAuthorization()
}
