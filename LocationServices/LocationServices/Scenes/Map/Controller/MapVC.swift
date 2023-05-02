//
//  MapVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

enum MapSearchState {
    case hidden
    case primaryVisible
    case onlySecondaryVisible
}

final class MapVC: UIViewController {
    
    var viewModel: MapViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private let mapContainerView = MapContainerView()
    private let mapSearchFloatingView = MapSearchFloatingView()
    
    weak var delegate: MapNavigationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationSearch(state: .onlySecondaryVisible)
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
        
        navigationItem.leftBarButtonItem = item
        if let sideBarButtonState {
            mapSearchFloatingView.setSideBarButtonState(sideBarButtonState)
        }
    }
    
    private func setupView() {
        view.addSubview(mapContainerView)
        
        mapContainerView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        mapSearchFloatingView.delegate = self
    }
}

extension MapVC: MapViewModelProtocolDelegate {
}

extension MapVC: MapSearchFloatingViewDelegate {
    func changeSplitState(to state: SideBarButtonState) {
        switch state {
        case .sidebar:
            delegate?.showPrimary()
        case .fullscreen:
            delegate?.showOnlySecondary()
        }
    }
    
    func searchActivated() {
        //TODO: show search view
    }
}
