//
//  MoreVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class MoreVC: UIViewController {
    let tableView: UITableView = {
        var tableView = UITableView()
        tableView.separatorColor = .searchBarTintColor
        return tableView
    }()
    
    weak var delegate: MoreNavigationDelegate?
    var viewModel: MoreViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        self.view.backgroundColor = .white
        self.navigationItem.title = StringConstant.AboutTab.title
        setupViews()
        setupTableView()
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}
