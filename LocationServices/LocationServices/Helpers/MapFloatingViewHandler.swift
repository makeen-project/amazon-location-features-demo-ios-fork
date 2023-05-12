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
    
    func setupNavigationSearch(state: MapSearchState, hideSearch: Bool = false) {
        let item: UIBarButtonItem?
        let sideBarButtonState: SideBarState?
        
        switch state {
        case .hidden:
            item = nil
            sideBarButtonState = nil
        case .primaryVisible:
            item = UIBarButtonItem(customView: mapSearchFloatingView)
            if hideSearch {
                sideBarButtonState = .onlyButtonSecondaryScreen
            } else {
                sideBarButtonState = .fullSecondaryScreen
            }
        case .onlySecondaryVisible:
            item = UIBarButtonItem(customView: mapSearchFloatingView)
            sideBarButtonState = .fullSideBar
        }
        
        viewController?.navigationItem.leftBarButtonItem = item
        if let sideBarButtonState {
            mapSearchFloatingView.setSideBarButtonState(sideBarButtonState)
        }
    }
}

extension MapFloatingViewHandler: MapSearchFloatingViewDelegate {
    func changeSplitState(to state: SideBarState) {
        switch state {
        case .fullSideBar:
            delegate?.showSupplementary()
        case .fullSecondaryScreen, .onlyButtonSecondaryScreen:
            delegate?.showOnlySecondary()
        }
    }
    
    func searchActivated() {
        //TODO: show search view
    }
}
