//
//  TrackingDashboard.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class TrackingDashboardController: UIViewController {
    
    weak var delegate: TrackingNavigationDelegate?
    var trackingHistoryHandler: VoidHandler?
    
    private var dashboardView = CommonDashboardView(
        title: StringConstant.enableTracking,
        detail: StringConstant.enableTrackingDescription,
        image: .trackingIcon,
        iconBackgroundColor: .white,
        buttonTitle: StringConstant.enableTracking
    )
    
    private let authActionsHelper = AuthActionsHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        navigationItem.backButtonTitle = ""
        setupHandlers()
        setupViews()
        authActionsHelper.delegate = delegate
        if UIDevice.current.userInterfaceIdiom == .pad {
            navigationController?.isNavigationBarHidden = false
        }
    }
    
    private func setupViews() {
        self.view.addSubview(dashboardView)
        dashboardView.snp.makeConstraints {
            $0.centerY.equalToSuperview().multipliedBy(0.9)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
    }
    
    private func setupHandlers() {
        dashboardView.dashboardButtonHandler = { [weak self] in
            self?.authActionsHelper.tryToPerformAuthAction { [weak self] in
                self?.trackingHistoryHandler?()
            }
        }
    }
}
