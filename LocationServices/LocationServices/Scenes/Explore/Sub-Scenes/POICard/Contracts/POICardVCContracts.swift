//
//  POICardVCContracts.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import Foundation

protocol POICardViewModelProcotol: AnyObject {
    var delegate: POICardViewModelOutputDelegate? { get set }
    
    func getMapModel() -> MapModel?
}

protocol POICardViewModelOutputDelegate: AnyObject, AlertPresentable {
    func populateDatas(cardData: MapModel, isLoadingData: Bool, errorMessage: String?, errorInfoMessage: String?)
    func dismissPoiView()
    func showDirectionView(seconDestination: MapModel)
    func updateSizeClass(_ sizeClass: POICardVC.DetentsSizeClass)
}

