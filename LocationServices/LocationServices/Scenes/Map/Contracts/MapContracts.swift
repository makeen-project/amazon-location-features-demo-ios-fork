//
//  MapContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol MapViewModelProtocol {
    var delegate: MapViewModelProtocolDelegate? { get set }
}

protocol MapViewModelProtocolDelegate: AnyObject {}
