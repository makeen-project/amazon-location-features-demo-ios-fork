//
//  SettingsVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class SettingsVC: UIViewController {
    
    enum Constants {
        static let horizontalOffset: CGFloat = 16
    }
    
    var delegate: SettingsNavigationDelegate?
    
    private var headerTitle: LargeTitleLabel = {
        let label = LargeTitleLabel(labelText: StringConstant.settigns)
        return label
    }()
    
    var tableView: UITableView = {
        var tableView = UITableView()
        if !UIDevice.current.isPad {
            tableView.separatorColor = .searchBarTintColor
            tableView.separatorInset = .init(top: 0, left: Constants.horizontalOffset, bottom: 0, right: Constants.horizontalOffset)
        } else {
            tableView.separatorStyle = .none
        }
        return tableView
    }()
    
    var viewModel: SettingsViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupNavigationItems()
        setupViews()
        setupTableView()
        viewModel.loadData()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
    }
    
    private func setupNavigationItems() {
        navigationController?.isNavigationBarHidden = !UIDevice.current.isPad
        navigationItem.backButtonTitle = ""
    }
   
    private func setupViews() {
        self.view.addSubview(headerTitle)
        self.view.addSubview(tableView)
    
        headerTitle.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().offset(Constants.horizontalOffset)
            $0.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.headerTitle.snp.bottom).offset(16)
            if UIDevice.current.userInterfaceIdiom == .phone {
                $0.leading.trailing.equalToSuperview()
            } else {
                $0.leading.trailing.equalToSuperview().inset(Constants.horizontalOffset)
            }
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(authorizationStatusChanged(_:)), name: Notification.authorizationStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeNotificationObservers(_:)), name: Notification.removeNotificationObservers, object: nil)
    }
    
    @objc private func authorizationStatusChanged(_ notification: Notification) {
    }
}

extension SettingsVC: SettingsViewModelOutputDelegate {
    func refreshViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
