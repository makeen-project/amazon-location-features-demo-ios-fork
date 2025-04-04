//
//  TrackingSimulationIntroController.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class TrackingSimulationIntroController: UIViewController {
    
    weak var delegate: TrackingNavigationDelegate?
    var trackingSimulationHandler: VoidHandler?
    var dismissHandler: VoidHandler?
    private var isiPad = UIDevice.current.userInterfaceIdiom == .pad
    
    private var dashboardView = TrackingSimulationDashboardView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .searchBarBackgroundColor
        navigationItem.backButtonTitle = ""
        setupHandlers()
        setupViews()
        if UIDevice.current.userInterfaceIdiom == .pad {
            navigationController?.isNavigationBarHidden = false
        }
    }
    
    private func setupViews() {
        self.view.addSubview(dashboardView)
        if UIDevice.current.userInterfaceIdiom == .pad {
            dashboardView.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(view.safeAreaLayoutGuide)
            }
        }
        else {
            dashboardView.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(view.safeAreaLayoutGuide)
            }
        }
    }
    
    private func setupHandlers() {
        dashboardView.dashboardButtonHandler = { [weak self] in
            self?.trackingSimulationHandler?()
        }
        dashboardView.maybeButtonHandler = { [weak self] in
            if self?.isiPad == true {
                self?.navigationController?.popViewController(animated: true)
            }
            else {
                self?.dismissBottomSheet()
            }
        }
    }
}
