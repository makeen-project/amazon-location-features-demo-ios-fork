//
//  TrackingEventModel.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

enum TrackerEventType: String, Codable {
    case enter = "ENTER"
    case exit = "EXIT"
}

struct TrackingEventModel: Codable {
    let trackerEventType: TrackerEventType
    let source: String
    let eventTime: String
    let geofenceId: String
}

// sample of object json:
//{"trackerEventType":"ENTER","source":"aws.geo","eventTime":"2023-02-20T13:10:39Z","geofenceId":"EmpireState"}
