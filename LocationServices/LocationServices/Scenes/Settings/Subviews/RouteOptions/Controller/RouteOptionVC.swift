//
//  RouteOptionVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class RouteOptionVC: UIViewController {
    
    private var routeOptions = RouteOptionRowView()
    
    var viewModel: RouteOptionViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHandlers()
        setupViews()
        viewModel.loadData()
    }
    
    private func setupViews() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .mapDarkBlackColor
        self.navigationItem.title = StringConstant.defaultRouteOptions
        self.view.backgroundColor = .white
        
        self.view.addSubview(routeOptions)
        
        routeOptions.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
    
    private func setupHandlers() {
        routeOptions.tollHandlers = { [weak self] option in
            self?.viewModel.saveTollOption(state: option)
        }
        
        routeOptions.ferriesHandlers = { [weak self] option in
            self?.viewModel.saveFerriesOption(state: option)
        }
    }
}

extension RouteOptionVC: RouteOptionViewModelOutputDelegate {
    func updateViews(tollOption: Bool, ferriesOption: Bool) {
        routeOptions.setLocalValues(toll: tollOption, ferries: ferriesOption)
    }
}
