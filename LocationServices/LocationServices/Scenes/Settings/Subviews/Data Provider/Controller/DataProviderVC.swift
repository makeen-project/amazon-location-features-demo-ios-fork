//
//  DataProviderVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class DataProviderVC: UIViewController {
    var selectedCell: Int = 0
    var viewModel: DataProviderViewModelProtocol! {
        didSet {
         viewModel.delegate = self
        }
    }
        
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupViews()
        viewModel.loadData()
    }
    
    private func setupViews() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .mapDarkBlackColor
        self.navigationItem.title = "Data Provider"
        self.view.backgroundColor = .white
        
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.bottom.trailing.equalToSuperview()
        }
    }
}

extension DataProviderVC: DataProviderViewModelOutputDelegate {
    func updateTableView(index: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.selectedCell = index
            self?.tableView.reloadData()
        }
    }
}
