//
//  GeofenceDashboardView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class GeofenceDashboardVC: UIViewController {
    weak var delegate: GeofenceNavigationDelegate?
    private var isInSplitViewController: Bool { delegate is SplitViewGeofencingMapCoordinator }
    var userlocation: (lat: Double?, long: Double?)?
    var addGeofence: Handler<(activeGeofences: [GeofenceDataModel], isEditingSceneEnabled: Bool, geofenceData: GeofenceDataModel?, userlocation: (lat: Double?, long: Double?)?)>?
    private let initialGeofenceView = InitialGeofenceView()
    private lazy var headerView: GeofenceDashboardHeaderView = {
        let offset: CGFloat = isInSplitViewController ? 0 : 25
        let view = GeofenceDashboardHeaderView(containerTopOffset: offset)
        return view
    }()
    
    var datas: [GeofenceDataModel] = []
    
    var viewModel: GeofenceDasboardViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private let authActionsHelper = AuthActionsHelper()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.accessibilityIdentifier = ViewsIdentifiers.Geofence.geofenceTableView
        tableView.backgroundColor = .searchBarBackgroundColor
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .searchBarBackgroundColor
        authActionsHelper.delegate = delegate
        navigationController?.isNavigationBarHidden = !isInSplitViewController
        setupHandlers()
        setupTableView()
        setupViews()
        setupNotification()
        setupViewsVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        geofenceAppearanceChanged(isVisible: true)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.geofenceMapLayerUpdate, object: nil, userInfo: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        geofenceAppearanceChanged(isVisible: false)
    }
    
    private func setupViews() {
        self.view.addSubview(headerView)
        self.view.addSubview(tableView)
        self.view.addSubview(initialGeofenceView)
        
        let headerViewHeight: CGFloat = isInSplitViewController ? 45 : 65
        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(headerViewHeight)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        initialGeofenceView.snp.makeConstraints {
            $0.centerY.equalToSuperview().multipliedBy(0.9)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
    }
    
    private func setupHandlers() {
        initialGeofenceView.geofenceButtonHandler = { [weak self] in
            self?.authActionsHelper.tryToPerformAuthAction { [weak self] in
                self?.headerView.isHidden = false
                self?.tableView.isHidden = false
                self?.initialGeofenceView.isHidden = true
                self?.tableView.reloadData()
            }
        }
        
        headerView.addButtonHandler = { [weak self] in
            self?.addGeofence?((self?.viewModel.geofences ?? [], false, nil, self?.userlocation))
        }
    }
    
    private func setupViewsVisibility() {
        if LoginViewModel.getAuthStatus() != .authorized {
            datas = []
        }
        
        let isGeofenceListEmpty = datas.isEmpty
        headerView.isHidden = isGeofenceListEmpty
        tableView.isHidden = isGeofenceListEmpty
        initialGeofenceView.isHidden = !isGeofenceListEmpty
        
        if isGeofenceListEmpty {
            Task {
                await viewModel.fetchListOfGeofences()
            }
        }
    }
    
    private func geofenceAppearanceChanged(isVisible: Bool) {
        let userInfo = ["isVisible" : isVisible]
        NotificationCenter.default.post(name: Notification.geofenceAppearanceChanged, object: nil, userInfo: userInfo)
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(authorizationStatusChanged(_:)), name: Notification.authorizationStatusChanged, object: nil)
    }
    
    @objc private func authorizationStatusChanged(_ notification: Notification) {
        self.setupViewsVisibility()
    }
}

extension GeofenceDashboardVC: GeofenceDasboardViewModelOutputProtocol {
    func refreshData(with model: [GeofenceDataModel]) {
        DispatchQueue.main.async { [weak self] in
            self?.datas = model
            if model.count > 0 {
                self?.headerView.isHidden = false
                self?.tableView.isHidden = false
                self?.initialGeofenceView.isHidden = true
            }
            self?.tableView.reloadData()
        }
    }
}
