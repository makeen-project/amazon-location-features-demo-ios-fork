//
//  UnitVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class UnitVC: UIViewController {
    var selectedCell: Int = 0
    var viewModel: UnitSceneViewModelProcotol! {
        didSet {
            self.viewModel.delegate = self
        }
    }
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadCurrentData()
        setupTableView()
        setupView()
    }
    
    
    private func setupView() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = .mapDarkBlackColor
        self.navigationItem.title = "Units"
        self.view.backgroundColor = .white
        
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
}

extension UnitVC: UnitSceneViewModelOutputDelegate {
    func updateTableView(index: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.selectedCell = index
            self?.tableView.reloadData()
        }
    }
}
