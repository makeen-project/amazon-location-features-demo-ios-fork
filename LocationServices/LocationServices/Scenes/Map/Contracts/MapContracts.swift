//
//  MapContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol MapNavigationDelegate: AnyObject, SplitViewVisibilityProtocol { }

protocol MapViewModelProtocol {
    var delegate: MapViewModelProtocolDelegate? { get set }
}

protocol MapViewModelProtocolDelegate: AnyObject {}

protocol MapSearchFloatingViewDelegate: AnyObject {
    func changeSplitState(to state: SideBarButtonState)
    func searchActivated()
}
