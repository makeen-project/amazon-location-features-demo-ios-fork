//
//  SettingsVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import AWSMobileClientXCF

final class SettingsVC: UIViewController {
    weak var delegate: SettingsNavigationDelegate?
    
    private var headerTitle: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = .amazonFont(type: .bold, size: 20)
        label.textAlignment = .left
        return label
    }()
    
    var tableView: UITableView = {
        var tableView = UITableView()
        tableView.separatorColor = .searchBarTintColor
        return tableView
    }()
    
    private lazy var logoutButton: SettingsLogoutButtonView = {
        let view = SettingsLogoutButtonView()
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(logoutAction))
        view.addGestureRecognizer(tap)
        return view
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
        // show logout button only if we are not signed in
        logoutButton.isHidden = !AWSMobileClient.default().isSignedIn
    }
    
    private func setupNavigationItems() {
        navigationController?.isNavigationBarHidden = !UIDevice.current.isPad
        navigationItem.backButtonTitle = ""
    }
    
    @objc func logoutAction() {
        viewModel.logOut()
    }
   
    private func setupViews() {
        self.view.addSubview(headerTitle)
        self.view.addSubview(logoutButton)
        self.view.addSubview(tableView)
        
        headerTitle.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview()
        }
        
        logoutButton.snp.makeConstraints {
            $0.height.equalTo(72)
            $0.bottom.equalTo(view.safeAreaInsets).offset(-16)
            $0.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.headerTitle.snp.bottom).offset(16)
            if UIDevice.current.userInterfaceIdiom == .phone {
                $0.leading.trailing.equalToSuperview()
            } else {
                $0.leading.trailing.equalToSuperview().inset(16)
            }
            $0.bottom.equalTo(logoutButton.snp.top)
        }
    }
}

extension SettingsVC: SettingsViewModelOutputDelegate {
    func refreshViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func logoutCompleted() {
        // show logout button only if we are not signed in
        self.logoutButton.isHidden = !AWSMobileClient.default().isSignedIn
    }
}
