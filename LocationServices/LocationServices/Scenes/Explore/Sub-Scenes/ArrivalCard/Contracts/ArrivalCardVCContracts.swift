//
//  ArrivalCardVCContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol ArrivalCardViewModelProcotol: AnyObject {
    var delegate: ArrivalCardViewModelOutputDelegate? { get set }
}

protocol ArrivalCardViewModelOutputDelegate: AnyObject, AlertPresentable {
    func dismissArrivalView()
    func updateSizeClass(_ sizeClass: ArrivalCardVC.DetentsSizeClass)
    func setArrivalHeight(_ height: CGFloat)
}
