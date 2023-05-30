//
//  SideBarVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class SideBarVC: UIViewController {
    
    enum Constants {
        static let horizontalOffset: CGFloat = 16
        static let tableViewVerticalOffset: CGFloat = 16
    }
    
    private let titleLabel: LargeTitleLabel = {
        let label = LargeTitleLabel(labelText: StringConstant.demo)
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
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(Constants.horizontalOffset)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-Constants.horizontalOffset)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Constants.tableViewVerticalOffset)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Constants.tableViewVerticalOffset)
        }
    }
}
