//
//  AboutVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class AboutVC: UIViewController {
    let tableView: UITableView = {
        var tableView = UITableView()
        tableView.separatorColor = .searchBarTintColor
        return tableView
    }()
    
    weak var delegate: AboutNavigationDelegate?
    var viewModel: AboutViewModelProtocol!
    
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
            if UIDevice.current.userInterfaceIdiom == .phone {
                $0.leading.trailing.equalToSuperview()
            } else {
                $0.leading.trailing.equalToSuperview().inset(16)
            }
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}
