//
//  BusRoutesData.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

struct BusRoutesData: Codable {
    let busRoutesData: [BusRoute]
}

struct BusRoute: Codable {
    let id: String
    let name: String
    let geofenceCollection: String
    let coordinates: [[Double]]
    let stopCoordinates: [BusStop]
}

struct BusStop: Codable {
    let type: String
    let stopGeometry: StopGeometry
    let stopProperties: StopProperties
    let id: Int
}

struct StopGeometry: Codable {
    let type: String
    let coordinates: [Double]
}

struct StopProperties: Codable {
    let id: Int
    let stop_id: String
    let stop_name: String
}
