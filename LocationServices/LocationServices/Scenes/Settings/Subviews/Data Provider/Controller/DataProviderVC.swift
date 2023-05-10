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
    
    private var screenTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .bold,
                                 size: 20)
        label.text = StringConstant.dataProvider
        return label
    }()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController?.isNavigationBarHidden = false
        } else {
            navigationController?.navigationBar.isHidden = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController?.isNavigationBarHidden = true
        } else {
            navigationController?.navigationBar.isHidden = false
        }
    }
    
    private func setupViews() {
        self.navigationController?.navigationBar.tintColor = .mapDarkBlackColor
        self.navigationItem.title = StringConstant.dataProvider
        self.view.backgroundColor = .white
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        if isPad {
            view.addSubview(screenTitleLabel)
            screenTitleLabel.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
                make.horizontalEdges.equalToSuperview().inset(24)
            }
        }
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            if isPad {
                $0.top.equalTo(screenTitleLabel.snp.bottom)
            } else {
                $0.top.equalTo(self.view.safeAreaLayoutGuide)
            }
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
