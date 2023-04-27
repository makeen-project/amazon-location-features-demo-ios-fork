//
//  MapVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class MapVC: UIViewController {
    
    var viewModel: MapViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private let mapContainerView = MapContainerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        view.addSubview(mapContainerView)
        
        mapContainerView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
    }
}

extension MapVC: MapViewModelProtocolDelegate {
}
