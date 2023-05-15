//
//  RouteOptionVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class RouteOptionVC: UIViewController {
    
    private var screenTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = .amazonFont(type: .bold,
                                 size: 20)
        label.text = StringConstant.defaultRouteOptions
        return label
    }()
    
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
        navigationController?.navigationBar.tintColor = .mapDarkBlackColor
        navigationItem.title = UIDevice.current.isPad ? "" :  StringConstant.defaultRouteOptions
        view.backgroundColor = .white
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        if isPad {
            view.addSubview(screenTitleLabel)
            screenTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
                make.horizontalEdges.equalToSuperview().inset(24)
            }
        }
        
        self.view.addSubview(routeOptions)
        routeOptions.snp.makeConstraints {
            if isPad {
                $0.top.equalTo(screenTitleLabel.snp.bottom)
            } else {
                $0.top.equalTo(self.view.safeAreaLayoutGuide)
            }
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
