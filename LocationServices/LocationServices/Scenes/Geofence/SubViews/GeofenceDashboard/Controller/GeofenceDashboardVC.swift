//
//  GeofenceDashboardView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class GeofenceDashboardVC: UIViewController {
    var userlocation: (lat: Double?, long: Double?)?
    var addGeofence: Handler<(activeGeofences: [GeofenceDataModel], isEditingSceneEnabled: Bool, geofenceData: GeofenceDataModel?, userlocation: (lat: Double?, long: Double?)?)>?
    private let initialGeofenceView = InitialGeofenceView()
    private let headerView = GeofenceDashboardHeaderView()
    

    var datas: [GeofenceDataModel] = []
    
    var viewModel: GeofenceDasboardViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
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
        setupHandlers()
        setupTableView()
        setupViews()
        
        let isGeofenceListEmpty = datas.isEmpty
        headerView.isHidden = isGeofenceListEmpty
        tableView.isHidden = isGeofenceListEmpty
        initialGeofenceView.isHidden = !isGeofenceListEmpty
        
        if isGeofenceListEmpty {
            viewModel.fetchListOfGeofences()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        geofenceAppearanceChanged(isVisible: true)
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
        
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(65)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        initialGeofenceView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupHandlers() {
        initialGeofenceView.geofenceButtonHandler = { [weak self] in
            self?.headerView.isHidden = false
            self?.tableView.isHidden = false
            self?.initialGeofenceView.isHidden = true
            self?.tableView.reloadData()
        }
        
        headerView.addButtonHandler = { [weak self] in
            self?.addGeofence?((self?.viewModel.geofences ?? [], false, nil, self?.userlocation))
        }
    }
    
    private func geofenceAppearanceChanged(isVisible: Bool) {
        let userInfo = ["isVisible" : isVisible]
        NotificationCenter.default.post(name: Notification.geofenceAppearanceChanged, object: nil, userInfo: userInfo)
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
