//
//  MapFloatingViewHandler.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

class MapFloatingViewHandler {
    
    enum Constants {
        static let leadingOffset: CGFloat = 16
        static let trailingOffset: CGFloat = 70
    }
    
    weak var delegate: SplitViewVisibilityProtocol?
    
    private weak var viewController: UIViewController?
    private let mapSearchFloatingView = MapSearchFloatingView()
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        
        mapSearchFloatingView.delegate = self
    }
    
    func setupNavigationSearch(state: MapSearchState, hideSearch: Bool = false) {
        mapSearchFloatingView.removeFromSuperview()
        
        let sideBarButtonState: SideBarState?
        
        switch state {
        case .hidden:
            sideBarButtonState = nil
        case .primaryVisible:
            if hideSearch {
                sideBarButtonState = .onlyButtonSecondaryScreen
            } else {
                sideBarButtonState = .fullSecondaryScreen
            }
        case .onlySecondaryVisible:
            sideBarButtonState = .fullSideBar
        }
        
        if let sideBarButtonState, let parentView = viewController?.view {
            mapSearchFloatingView.setSideBarButtonState(sideBarButtonState)
            parentView.addSubview(mapSearchFloatingView)
            
            mapSearchFloatingView.snp.makeConstraints {
                $0.top.equalTo(parentView.safeAreaLayoutGuide)
                $0.leading.equalToSuperview().offset(Constants.leadingOffset)
                $0.trailing.lessThanOrEqualToSuperview().offset(-Constants.trailingOffset)
            }
        }
    }
    
    func setSideBarButtonVisibility(isHidden: Bool) {
        mapSearchFloatingView.setSideBarButtonVisibility(isHidden: isHidden)
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
        delegate?.showSearchScene()
    }
}
