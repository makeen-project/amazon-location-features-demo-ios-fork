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
        label.font = .amazonFont(type: .bold, size: 24)
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
    
    private func setupNavigationItems() {
        self.navigationItem.backButtonTitle = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
        if UIDevice.current.userInterfaceIdiom == .pad {
            navigationController?.isNavigationBarHidden = true
        }
        // show logout button only if we are not signed in
        self.logoutButton.isHidden = !AWSMobileClient.default().isSignedIn
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if UIDevice.current.userInterfaceIdiom == .pad {
            navigationController?.isNavigationBarHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController?.isNavigationBarHidden = true
        }
        setupNavigationItems()
        setupViews()
        setupTableView()
        viewModel.loadData()
    }
    
    @objc func logoutAction() {
        viewModel.logOut()
    }
   
    private func setupViews() {
        self.view.addSubview(headerTitle)
        self.view.addSubview(logoutButton)
        self.view.addSubview(tableView)
        
        headerTitle.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(32)
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
