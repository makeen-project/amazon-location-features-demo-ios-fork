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
    
    private lazy var settingsButton: SettingsButtonView = {
        let view = SettingsButtonView()
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(buttonAction))
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
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadData()
        updateLogoutButtonVisibility()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    private func setupNavigationItems() {
        navigationController?.isNavigationBarHidden = !UIDevice.current.isPad
        navigationItem.backButtonTitle = ""
    }
    
    @objc func buttonAction() {
        switch UserDefaultsHelper.getAppState() {
        case .loggedIn:
            self.viewModel.logOut()
        case .customAWSConnected:
            self.viewModel.disconnectAWS()
        default:
            print("no action required")
        }
    }
   
    private func setupViews() {
        self.view.addSubview(headerTitle)
        self.view.addSubview(tableView)
        self.view.addSubview(settingsButton)
    
        headerTitle.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().offset(Constants.horizontalOffset)
            $0.trailing.equalToSuperview()
        }
        
        settingsButton.snp.makeConstraints {
            $0.height.equalTo(72)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaInsets).offset(-16)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.headerTitle.snp.bottom).offset(16)
            if UIDevice.current.userInterfaceIdiom == .phone {
                $0.leading.trailing.equalToSuperview()
            } else {
                $0.leading.trailing.equalToSuperview().inset(Constants.horizontalOffset)
            }
            $0.bottom.equalTo(settingsButton.snp.top)
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(authorizationStatusChanged(_:)), name: Notification.authorizationStatusChanged, object: nil)
    }
    
    @objc private func authorizationStatusChanged(_ notification: Notification) {
        self.updateLogoutButtonVisibility()
    }
    
    private func updateLogoutButtonVisibility() {
        // show logout & disconnect button
        DispatchQueue.main.async {
            switch UserDefaultsHelper.getAppState() {
            case .loggedIn:
                self.settingsButton.setButtonState(settingsButtonState: .logout)
                self.settingsButton.isHidden = false
            case .customAWSConnected:
                self.settingsButton.setButtonState(settingsButtonState: .disconnect)
                self.settingsButton.isHidden = false
            default:
                self.settingsButton.isHidden = true
            }
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
        updateLogoutButtonVisibility()
    }
}
