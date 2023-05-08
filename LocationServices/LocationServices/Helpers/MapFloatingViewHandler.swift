//
//  MapFloatingViewHandler.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

class MapFloatingViewHandler {
    weak var delegate: SplitViewVisibilityProtocol?
    
    private weak var viewController: UIViewController?
    private let mapSearchFloatingView = MapSearchFloatingView()
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        
        mapSearchFloatingView.delegate = self
    }
    
    func setupNavigationSearch(state: MapSearchState) {
        let item: UIBarButtonItem?
        let sideBarButtonState: SideBarButtonState?
        
        switch state {
        case .hidden:
            item = nil
            sideBarButtonState = nil
        case .primaryVisible:
            item = UIBarButtonItem(customView: mapSearchFloatingView)
            sideBarButtonState = .fullscreen
        case .onlySecondaryVisible:
            item = UIBarButtonItem(customView: mapSearchFloatingView)
            sideBarButtonState = .sidebar
        }
        
        viewController?.navigationItem.leftBarButtonItem = item
        if let sideBarButtonState {
            mapSearchFloatingView.setSideBarButtonState(sideBarButtonState)
        }
    }
}

extension MapFloatingViewHandler: MapSearchFloatingViewDelegate {
    func changeSplitState(to state: SideBarButtonState) {
        switch state {
        case .sidebar:
            delegate?.showSupplementary()
        case .fullscreen:
            delegate?.showOnlySecondary()
        }
    }
    
    func searchActivated() {
        //TODO: show search view
    }
}
