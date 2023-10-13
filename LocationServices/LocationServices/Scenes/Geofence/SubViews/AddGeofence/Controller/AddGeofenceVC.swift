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
    private var isInSplitViewController: Bool { delegate is SplitViewGeofencingMapCoordinator }
    
    var userLocation: (lat: Double?, long: Double?)?
    private var cacheSaveModel: GeofenceDataModel = GeofenceDataModel(id: nil,
                                                                      lat: nil,
                                                                      long: nil,
                                                                      radius: 80)
    
    // MARK - UI Elements
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.accessibilityIdentifier = ViewsIdentifiers.Geofence.addGeofenceTableView
        tableView.backgroundColor = .searchBarBackgroundColor
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var headerView: AddGeofenceHeaderView = {
        return AddGeofenceHeaderView(isEditinSceneEnabled: isEditingSceneEnabled, showCloseButton: !isInSplitViewController)
    }()
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
        
        let barButtonItem = UIBarButtonItem(title: nil, image: .chevronBackward, target: self, action: #selector(closeScreen))
        barButtonItem.tintColor = .lsPrimary
        navigationItem.leftBarButtonItem = barButtonItem
        
        title = StringConstant.addGeofence
        updateTitle(largeTitleVisibility: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardNotifications()
        NotificationCenter.default.post(name: Notification.enableGeofenceDrag, object: nil, userInfo: ["enableGeofenceDrag": true])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
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
    
    private func setupFieldsInitDatas() {
        searchView.updateFields(model: cacheSaveModel)
        
        // it means it is already existing geofence
        if let title = cacheSaveModel.id, title.isEmpty == false {
            nameTextField.setTitle(title: title)
        }
    }
    
    func update(lat: Double?, long: Double?) {
        changeElementVisibility(state: false)
        let model = GeofenceDataModel(id: cacheSaveModel.id,
                                      lat: lat,
                                      long: long,
                                      radius: 80)
        searchView.updateFields(model: model)
        self.cacheSaveModel = model
        self.enableSaveButton()
        self.postNotification(model: model)
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
            self?.closeScreen()
        }
    }
    
    @objc private func closeScreen() {
        sentGeofenceRefreshNotification = true
        NotificationCenter.default.post(name: Notification.enableGeofenceDrag, object: nil, userInfo: ["enableGeofenceDrag": false])
        NotificationCenter.default.post(name: Notification.refreshGeofence, object: nil, userInfo: ["hardRefresh": false])
        delegate?.dismissCurrentScene(geofences: viewModel.activeGeofencesLists, shouldDashboardShow: false)
        self.delegate?.dismissCurrentBottomSheet(geofences: self.viewModel.activeGeofencesLists, shouldDashboardShow: true)
    }
    
    private func setupViews() {
        changeState(isTableViewHidden: true)
        self.tableView.keyboardDismissMode = .onDrag
        self.deleteButton.isHidden = !isEditingSceneEnabled
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(headerView)
        containerView.addSubview(searchView)
        containerView.addSubview(nameTextField)
        containerView.addSubview(saveButton)
        containerView.addSubview(deleteButton)
        
        self.view.addSubview(tableView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(30)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
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
            $0.bottomMargin.equalToSuperview().offset(-20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func changeState(isTableViewHidden: Bool) {
        tableView.isHidden = isTableViewHidden
        nameTextField.isHidden = !isTableViewHidden
        deleteButton.isHidden = !isEditingSceneEnabled || !isTableViewHidden
        saveButton.isHidden = !isTableViewHidden
        
        tableView.contentOffset.y = 0
        scrollView.contentOffset.y = 0
        
        tableView.isScrollEnabled = !isTableViewHidden
        scrollView.isScrollEnabled = isTableViewHidden
    }
    
    func changeElementVisibility(state: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.searchView.hideRadiusViews(state: state)
            self?.changeState(isTableViewHidden: !state)
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
                if(UIDevice.current.userInterfaceIdiom == .phone){
                    self?.delegate?.dismissCurrentBottomSheet(geofences: self?.viewModel.activeGeofencesLists ?? [], shouldDashboardShow: true)
                }
                else {
                    self?.closeScreen()
                }
               
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
    
    private func updateTitle(largeTitleVisibility: CGFloat) {
        guard let navigationController else { return }
        let navigationBar = navigationController.navigationBar
        
        let appearances = [navigationBar.scrollEdgeAppearance, navigationBar.standardAppearance, navigationBar.compactAppearance]
        appearances.forEach {
            $0?.titleTextAttributes = [
                .font: UIFont.amazonFont(type: .bold, size: 16),
                .foregroundColor: UIColor.lsTetriary.withAlphaComponent(1 - largeTitleVisibility)
            ]
        }
    }
}

extension AddGeofenceVC: AddGeofenceViewModelOutputProtocol {
    func selectedPlaceResult(mapModel: MapModel) {
        update(lat: mapModel.placeLat, long: mapModel.placeLong)
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
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc override func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let additionalOffset = keyboardSize.height - view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = additionalOffset
    }
    
    @objc override func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
    }
}

extension AddGeofenceVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView {
        case self.scrollView:
            processScrollViewDidScroll()
        default:
            break
        }
    }
    
    private func processScrollViewDidScroll() {
        guard let rootView = navigationController?.navigationBar.superview,
              let navigationBarFrame = navigationController?.navigationBar.frame,
              !headerView.titleLabel.frame.isEmpty else { return }
        
        let largeTitleInRootViewFrame = rootView.convert(headerView.titleLabel.frame, from: headerView)
        
        let distance = max(0, navigationBarFrame.maxY - largeTitleInRootViewFrame.minY)
        let largeTitleVisibility = 1 - min(1, distance / largeTitleInRootViewFrame.height)
        
        headerView.titleLabel.alpha = largeTitleVisibility
        updateTitle(largeTitleVisibility: largeTitleVisibility)
    }
}
