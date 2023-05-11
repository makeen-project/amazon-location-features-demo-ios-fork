//
//  SearchVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import CoreLocation

final class SearchVC: UIViewController {
    weak var delegate: ExploreNavigationDelegate?
    private var isInSplitViewController: Bool { delegate is SplitViewExploreMapCoordinator }
    
    var userLocation: (lat: Double?, long: Double?)? {
        didSet {
            guard let lat = userLocation?.lat,
                  let long = userLocation?.long else {
                return
            }
            
            let userLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
            guard !CLLocationCoordinate2DIsValid(userLocation) else { return }
            self.userLocation = nil
        }
    }
    
    var isInitalState: Bool = true
    private var clearAnnotationsOnDisappear = true
    
    private lazy var searchBarView: SearchBarView = {
        SearchBarView(becomeFirstResponder: false, showGrabberIcon: !isInSplitViewController)
    }()
    
    // TODO: can be created later, marked with optional
    //var searchBarView: SearchBarView = SearchBarView(isAccountBarEnabled: false)
    
    var viewModel: SearchViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .searchBarBackgroundColor
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = ViewsIdentifiers.Search.searchRootView
        view.backgroundColor = .searchBarBackgroundColor
        searchBarView.delegate = self
        setupTableView()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        searchAppearanceChanged(isVisible: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if clearAnnotationsOnDisappear {
            clearAnnotations()
        }
        clearAnnotationsOnDisappear = true
        searchAppearanceChanged(isVisible: false)
    }
    
    private func searchAppearanceChanged(isVisible: Bool) {
        let userInfo = ["isVisible" : isVisible]
        NotificationCenter.default.post(name: Notification.searchAppearanceChanged, object: nil, userInfo: userInfo)
    }
    
    private func clearAnnotations() {
        let coordinates = ["coordinates" : []]
        NotificationCenter.default.post(name: Notification.userLocation, object: nil, userInfo: coordinates)
    }
    
    private func setupViews() {
        view.addSubview(searchBarView)
        view.addSubview(tableView)
        
        searchBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(76)
            $0.leading.trailing.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func applyMediumSheetPresentation() {
        self.view.endEditing(true)
        guard let sheet = self.sheetPresentationController else { return }
        sheet.animateChanges {
            sheet.selectedDetentIdentifier = .medium
        }
    }
}

extension SearchVC: SearchViewModelOutputDelegate {
    func searchResult(mapModel: [MapModel], shouldDismiss: Bool, showOnMap: Bool) {
        isInitalState = false
        let coordinates = ["coordinates" : mapModel]
        NotificationCenter.default.post(name: Notification.userLocation, object: nil, userInfo: coordinates)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if showOnMap {
                self.applyMediumSheetPresentation()
            }
        }
    }
    
    func selectedPlaceResult(mapModel: MapModel) {
        clearAnnotationsOnDisappear = false
        let coordinates = ["place" : mapModel]
        NotificationCenter.default.post(name: Notification.selectedPlace, object: nil, userInfo: coordinates)
    }
}

extension SearchVC: SearchBarViewOutputDelegate {    
    func searchText(_ text: String?) {
        viewModel.searchWithSuggesstion(text: text ?? "", userLat: userLocation?.lat, userLong: userLocation?.long)
    }
    
    func searchTextWith(_ text: String?) {
        viewModel.searchWith(text: text ?? "", userLat: userLocation?.lat, userLong: userLocation?.long)
    }
}
