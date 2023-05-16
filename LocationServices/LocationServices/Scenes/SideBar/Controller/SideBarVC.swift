//
//  SideBarVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SideBarVC: UIViewController {
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .bold, size: 20)
        label.textColor = .black
        label.text = StringConstant.demo
        return label
    }()
    
    let tableView: UITableView = {
        var tableView = UITableView()
        return tableView
    }()
    
    weak var delegate: SideBarDelegate?
    var viewModel: SideBarViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupViews()
        setupTableView()
    }
    
    private func setupViews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
    }
}
