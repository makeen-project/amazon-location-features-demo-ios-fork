//
//  ExploreMapStyleVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
final class ExploreMapStyleVC: UIViewController {
    let datas: [MapStyleSourceType] =  [.esri, .here]
    var dismissHandler: VoidHandler?
    
    var selectedIndex: Int = 0
    var headerView: ExploreMapStyleHeaderView = ExploreMapStyleHeaderView()
    
    
    var viewModel: ExploreMapStyleViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    var tableView: UITableView =  {
       let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHandlers()
        setupTableView()
        setupViews()
        viewModel.loadData()
    }
    
    private func setupHandlers() {
        self.headerView.dismissHandler = { [weak self] in
            self?.dismissHandler?()
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .searchBarBackgroundColor
        self.view.addSubview(headerView)
        self.view.addSubview(tableView)
        
        headerView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().offset(-5)
            $0.bottom.equalToSuperview()
        }
    }
}

extension ExploreMapStyleVC: ExploreMapStyleViewModelOutputDelegate {
    func updateTableView(item: Int) {
        selectedIndex = item
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
