//
//  AboutVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class AboutVC: UIViewController {
    
    private var screenTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .amazonFont(type: .bold,
                                 size: 20)
        label.text = StringConstant.about
        return label
    }()
    
    let tableView: UITableView = {
        var tableView = UITableView()
        tableView.separatorColor = .searchBarTintColor
        return tableView
    }()
    
    weak var delegate: AboutNavigationDelegate?
    var viewModel: AboutViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
        view.backgroundColor = .white
        navigationItem.title = UIDevice.current.isPad ? "" : StringConstant.AboutTab.title
        setupViews()
        setupTableView()
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        let isPad = UIDevice.current.isPad
        if isPad {
            view.addSubview(screenTitleLabel)
            screenTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
                make.leading.equalToSuperview().offset(24)
            }
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(
                isPad ? screenTitleLabel.snp.bottom : view.safeAreaLayoutGuide
            ).offset(
                isPad ? 16 : 24
            )
            $0.horizontalEdges.equalToSuperview().inset(isPad ? 16 : 0)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}
