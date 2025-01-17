//
//  RouteModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation
import CoreLocation

struct RouteModel: Codable {
    var departurePosition: CLLocationCoordinate2D
    let destinationPosition: CLLocationCoordinate2D
    let travelMode: RouteTypes
    let avoidFerries: Bool
    let avoidTolls: Bool
    let avoidUturns: Bool
    let avoidTunnels: Bool
    let avoidDirtRoads: Bool
    let isPreview: Bool
    let departurePlaceName: String?
    let departurePlaceAddress: String?
    let destinationPlaceName: String?
    let destinationPlaceAddress: String?
    let departNow: Bool?
    let departureTime: Date?
    let arrivalTime: Date?

    // Custom Coding Keys
    enum CodingKeys: String, CodingKey {
        case departurePosition
        case destinationPosition
        case travelMode
        case avoidFerries
        case avoidTolls
        case avoidUturns
        case avoidTunnels
        case avoidDirtRoads
        case isPreview
        case departurePlaceName
        case departurePlaceAddress
        case destinationPlaceName
        case destinationPlaceAddress
        case departNow
        case departureTime
        case arrivalTime
    }

    // Custom Encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // Encode CLLocationCoordinate2D as a dictionary
        try container.encode([departurePosition.latitude, departurePosition.longitude], forKey: .departurePosition)
        try container.encode([destinationPosition.latitude, destinationPosition.longitude], forKey: .destinationPosition)

        // Encode the rest
        try container.encode(travelMode, forKey: .travelMode)
        try container.encode(avoidFerries, forKey: .avoidFerries)
        try container.encode(avoidTolls, forKey: .avoidTolls)
        try container.encode(avoidUturns, forKey: .avoidUturns)
        try container.encode(avoidTunnels, forKey: .avoidTunnels)
        try container.encode(avoidDirtRoads, forKey: .avoidDirtRoads)
        try container.encode(isPreview, forKey: .isPreview)
        try container.encode(departurePlaceName, forKey: .departurePlaceName)
        try container.encode(departurePlaceAddress, forKey: .departurePlaceAddress)
        try container.encode(destinationPlaceName, forKey: .destinationPlaceName)
        try container.encode(destinationPlaceAddress, forKey: .destinationPlaceAddress)
        try container.encode(departNow, forKey: .departNow)
        try container.encode(departureTime, forKey: .departureTime)
        try container.encode(arrivalTime, forKey: .arrivalTime)
    }

    // Custom Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode CLLocationCoordinate2D from a dictionary
        let departureCoordinates = try container.decode([Double].self, forKey: .departurePosition)
        departurePosition = CLLocationCoordinate2D(latitude: departureCoordinates[0], longitude: departureCoordinates[1])

        let destinationCoordinates = try container.decode([Double].self, forKey: .destinationPosition)
        destinationPosition = CLLocationCoordinate2D(latitude: destinationCoordinates[0], longitude: destinationCoordinates[1])

        // Decode the rest
        travelMode = try container.decode(RouteTypes.self, forKey: .travelMode)
        avoidFerries = try container.decode(Bool.self, forKey: .avoidFerries)
        avoidTolls = try container.decode(Bool.self, forKey: .avoidTolls)
        avoidUturns = try container.decode(Bool.self, forKey: .avoidUturns)
        avoidTunnels = try container.decode(Bool.self, forKey: .avoidTunnels)
        avoidDirtRoads = try container.decode(Bool.self, forKey: .avoidDirtRoads)
        isPreview = try container.decode(Bool.self, forKey: .isPreview)
        departurePlaceName = try container.decodeIfPresent(String.self, forKey: .departurePlaceName)
        departurePlaceAddress = try container.decodeIfPresent(String.self, forKey: .departurePlaceAddress)
        destinationPlaceName = try container.decodeIfPresent(String.self, forKey: .destinationPlaceName)
        destinationPlaceAddress = try container.decodeIfPresent(String.self, forKey: .destinationPlaceAddress)
        departNow = try container.decode(Bool.self, forKey: .departNow)
        departureTime = try container.decodeIfPresent(Date.self, forKey: .departureTime)
        arrivalTime = try container.decodeIfPresent(Date.self, forKey: .arrivalTime)
    }
    
    init(
            departurePosition: CLLocationCoordinate2D,
            destinationPosition: CLLocationCoordinate2D,
            travelMode: RouteTypes,
            avoidFerries: Bool,
            avoidTolls: Bool,
            avoidUturns: Bool,
            avoidTunnels: Bool,
            avoidDirtRoads: Bool,
            isPreview: Bool,
            departurePlaceName: String? = nil,
            departurePlaceAddress: String? = nil,
            destinationPlaceName: String? = nil,
            destinationPlaceAddress: String? = nil,
            departNow: Bool? = nil,
            departureTime: Date? = nil,
            arrivalTime: Date? = nil
        ) {
            self.departurePosition = departurePosition
            self.destinationPosition = destinationPosition
            self.travelMode = travelMode
            self.avoidFerries = avoidFerries
            self.avoidTolls = avoidTolls
            self.avoidUturns = avoidUturns
            self.avoidTunnels = avoidTunnels
            self.avoidDirtRoads = avoidDirtRoads
            self.isPreview = isPreview
            self.departurePlaceName = departurePlaceName
            self.departurePlaceAddress = departurePlaceAddress
            self.destinationPlaceName = destinationPlaceName
            self.destinationPlaceAddress = destinationPlaceAddress
            self.departNow = departNow
            self.departureTime = departureTime
            self.arrivalTime = arrivalTime
        }
}


