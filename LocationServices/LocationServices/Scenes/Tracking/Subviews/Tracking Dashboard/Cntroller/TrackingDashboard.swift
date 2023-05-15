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
    
    private var dashboardView = CommonDashboardView(
        title: StringConstant.enableTracking,
        detail: StringConstant.enableTrackingDescription,
        image: .trackingIcon,
        iconBackgroundColor: .white,
        buttonTitle: StringConstant.enableTracking,
        showMaybeLater: UIDevice.current.userInterfaceIdiom == .phone
    )
    
    var viewModel: TrackingDashboardViewModelProcotol! {
        didSet {
            viewModel.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        navigationItem.backButtonTitle = ""
        setupHandlers()
        setupViews()
        if UIDevice.current.userInterfaceIdiom == .pad {
            navigationController?.isNavigationBarHidden = false
        }
    }
    
    private func setupViews() {
        self.view.addSubview(dashboardView)
        dashboardView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
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
