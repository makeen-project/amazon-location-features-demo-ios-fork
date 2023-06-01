//
//  AddGeofenceVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import CoreLocation

final class AddGeofenceVC: UIViewController {
    var isEditingSceneEnabled: Bool = false
    var isInitalState: Bool = true
    
    weak var delegate: GeofenceNavigationDelegate?
    
    var userLocation: (lat: Double?, long: Double?)?
    private var cacheSaveModel: GeofenceDataModel = GeofenceDataModel(id: nil,
                                                                      lat: nil,
                                                                      long: nil,
                                                                      radius: 80)
    
    // MARK - UI Elements
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .searchBarBackgroundColor
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private lazy var headerView = AddGeofenceHeaderView(isEditinSceneEnabled: isEditingSceneEnabled)
    lazy var searchView = AddGeofenceSearchView()
    private lazy var nameTextField = AddGeofenceNameTextField()
    
    private lazy var saveButton: AmazonLocationButton = {
        let button = AmazonLocationButton(title: "Save")
        button.accessibilityIdentifier = ViewsIdentifiers.Geofence.saveGeofenceButton
        button.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        button.changeButton(state: true)
        return button
    }()
    
    private lazy var deleteButton: AmazonLocationButton = {
        let button = AmazonLocationButton(title: "Delete")
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        button.backgroundColor = .navigationRedButton
        return button
    }()
    
    var viewModel: AddGeofenceViewModelProcotol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private var sentGeofenceRefreshNotification = false
    
    init(model: GeofenceDataModel?) {
        super.init(nibName: nil, bundle: nil)
        if let model = model {
            cacheSaveModel = model
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError(.errorInitWithCoder)
    }
    
    private func setupFieldsInitDatas() {
        searchView.updateFields(model: cacheSaveModel)
        
        // it means it is already existing geofence
        if let title = cacheSaveModel.id, title.isEmpty == false {
            nameTextField.setTitle(title: title)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.geofenceMapLayerUpdate, object: nil, userInfo: nil)
        NotificationCenter.default.post(name: Notification.deselectMapAnnotation, object: nil, userInfo: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !sentGeofenceRefreshNotification {
            NotificationCenter.default.post(name: Notification.refreshGeofence, object: nil, userInfo: ["hardRefresh": false])
        }
        sentGeofenceRefreshNotification = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if cacheSaveModel.lat == nil && cacheSaveModel.long == nil,
           let lat = userLocation?.lat, let long = userLocation?.long {
            cacheSaveModel.lat = lat
            cacheSaveModel.long = long
        }
        postNotification(model: cacheSaveModel)
        
        nameTextField.setEditableStatus(!isEditingSceneEnabled)
        view.backgroundColor = .searchBarBackgroundColor
        setupHandlers()
        setupViews()
        setupFieldsInitDatas()
        setupTableView()
    }
    
    private func setupHandlers() {
        nameTextField.passChangedText = { [weak self] value in
            self?.cacheSaveModel.id = value
            self?.enableSaveButton()
        }
        
        nameTextField.validationCallback = viewModel.isGeofenceNameValid(_:)
        
        searchView.radiusValueHander = { [weak self] value in
            self?.cacheSaveModel.radius = Int64(value)
            self?.enableSaveButton()
            
            guard self?.cacheSaveModel.lat != nil, self?.cacheSaveModel.long != nil else {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                guard let self = self else  { return }
                self.postNotification(model: self.cacheSaveModel)
            }

        }
        
        searchView.coordinateValueHandler =  { [weak self] value in
            let lat = value.0
            let long = value.1
            
            self?.cacheSaveModel.lat = lat
            self?.cacheSaveModel.long = long
        }
        
        searchView.searchTextValue = { [weak self] value in
            self?.changeElementVisibility(state: true)
            self?.viewModel.searchWithSuggesstion(text: value,
                                                  userLat: self?.userLocation?.lat,
                                                  userLong: self?.userLocation?.long)
        }
        
        searchView.searchTextClose = {[weak self] in
            self?.viewModel.searchWithSuggesstion(text: "",
                                                  userLat: nil,
                                                  userLong: nil)
            self?.changeElementVisibility(state: false)
        }
        
        headerView.dismissHandler = { [weak self] in
            self?.sentGeofenceRefreshNotification = true
            NotificationCenter.default.post(name: Notification.refreshGeofence, object: nil, userInfo: ["hardRefresh": false])
            self?.delegate?.dismissCurrentBottomSheet(geofences: self?.viewModel.activeGeofencesLists ?? [], shouldDashboardShow: true)
        }
    }
    
    private func setupViews() {
        self.tableView.isHidden = true
        self.tableView.keyboardDismissMode = .onDrag
        self.deleteButton.isHidden = !isEditingSceneEnabled
        
        let scrollView = UIScrollView()
        let contentView = UIView()

        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        contentView.addSubview(searchView)
        contentView.addSubview(nameTextField)
        contentView.addSubview(saveButton)
        contentView.addSubview(deleteButton)
        contentView.addSubview(tableView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.width.equalTo(scrollView)
        }

        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.height.equalTo(50)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        searchView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(110)
        }
        
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(searchView.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalTo(saveButton.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(48)
            $0.bottomMargin.equalToSuperview().offset(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
    }
    
    func changeElementVisibility(state: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.searchView.hideRadiusViews(state: state)
            self?.tableView.isHidden = !state
            self?.nameTextField.isHidden = state
            self?.deleteButton.isHidden = !(self?.isEditingSceneEnabled ?? false)
            self?.saveButton.isHidden = state
            self?.searchView.snp.updateConstraints {
                $0.height.equalTo(state ? 50 : 110)
            }
        }
    }
    
    func enableSaveButton() {
        let state = !viewModel.isGeofenceModelValid(cacheSaveModel)
        
        DispatchQueue.main.async { [weak self] in
            self?.saveButton.changeButton(state: state)
        }
    }
    
    @objc private func saveAction() {
        guard let id = cacheSaveModel.id,
              let radius = cacheSaveModel.radius,
              let lat = cacheSaveModel.lat,
              let long = cacheSaveModel.long else {
            return
        }
  
        viewModel.saveData(with: id, lat: lat, long: long, radius: Int(radius)) { [weak self] result in
            switch result {
            case .success:
                self?.sentGeofenceRefreshNotification = true
                NotificationCenter.default.post(name: Notification.geofenceAdded, object: nil, userInfo: ["model": self?.cacheSaveModel as Any])
                self?.delegate?.dismissCurrentBottomSheet(geofences: self?.viewModel.activeGeofencesLists ?? [], shouldDashboardShow: true)
            case .failure(let error):
                let model = AlertModel(title: StringConstant.error, message: error.localizedDescription, cancelButton: nil)
                self?.showAlert(model)
            }
        }
    }
    
    @objc private func deleteAction() {
        guard viewModel.isGeofenceModelValid(cacheSaveModel) else { return }
        viewModel.deleteData(with: cacheSaveModel)
    }
    
    private func setupMapAnnotation() {
        
    }
    
    private func deleteNotification(model: GeofenceDataModel?) {
        if let id = model?.id {
            let geofenceModel = ["id" : id]
            sentGeofenceRefreshNotification = true
            NotificationCenter.default.post(name: Notification.deleteGeofenceData, object: nil, userInfo: geofenceModel)
        }
    }
    
    private func postNotification(model: GeofenceDataModel?) {
        if let model = model {
            let geofenceModel = ["geofenceModel" : model]
            NotificationCenter.default.post(name: Notification.geofenceEditScene, object: nil, userInfo: geofenceModel)
        }
    }
}

extension AddGeofenceVC: AddGeofenceViewModelOutputProtocol {
    func selectedPlaceResult(mapModel: MapModel) {
        
        changeElementVisibility(state: false)
        let model = GeofenceDataModel(id: cacheSaveModel.id,
                                      lat: mapModel.placeLat,
                                      long: mapModel.placeLong,
                                      radius: 80)
        searchView.updateFields(model: model)
        self.cacheSaveModel = model
        self.enableSaveButton()
        self.postNotification(model: model)
    }
    
    func searchResult(mapModel: [MapModel]) {
        isInitalState = false
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func finishProcess() {
        deleteNotification(model: cacheSaveModel)
        self.delegate?.dismissCurrentBottomSheet(geofences: viewModel.activeGeofencesLists, shouldDashboardShow: true)
    }
}
