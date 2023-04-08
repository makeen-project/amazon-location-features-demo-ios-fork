//
//  TrackingDashboard.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class TrackingDashboardController: UIViewController {
    
    var trackingHistoryHandler: VoidHandler?
    var closeHandler: VoidHandler?
    
    private var dashboardView: CommonDashboardView = CommonDashboardView(title: "Enable Tracking",
                                                                         detail: "Tracking allows us to send you geofence messages when you enter and leave locations",
                                                                         image: .trackingIcon,
                                                                         iconBackgroundColor: .white,
                                                                         buttonTitle: "Enable Tracking")
    
    var viewModel: TrackingDashboardViewModelProcotol! {
        didSet {
            viewModel.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupHandlers()
        setupViews()
    }
    
    private func setupViews() {
        self.view.addSubview(dashboardView)
        dashboardView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupHandlers() {
        dashboardView.maybeLaterButtonHander = { [weak self] in
            self?.viewModel.saveData(state: false)
        }
        
        dashboardView.dashboardButtonHandler = { [weak self] in
            self?.viewModel.saveData(state: true)
        }
    }
    
}

extension TrackingDashboardController: TrackingDashboardViewModelOutputProtocol {
    func openHistoryPage() {
        trackingHistoryHandler?()
    }
    
    func close() {
        closeHandler?()
    }
}
