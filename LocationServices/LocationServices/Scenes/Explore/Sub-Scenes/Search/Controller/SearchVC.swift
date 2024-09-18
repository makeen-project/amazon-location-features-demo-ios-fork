//
//  SearchVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit
import CoreLocation

struct SearchScreenStyle {
    var backgroundColor: UIColor
    var searchBarStyle: SearchBarStyle
}

final class SearchVC: UIViewController {
    
    enum Constants {
        static let searchBarHeightiPhone: CGFloat = 76
        static let searchBarHeightiPad: CGFloat = 40
        static let searchBarHorizontalPaddingiPhone: CGFloat = 16
        static let searchBarHorizontalPaddingiPad: CGFloat = 0
        
        static let tableViewHorizontalOffset: CGFloat = 0
        static let tableViewTopOffsetiPhone: CGFloat = 16
    }
    
    weak var delegate: ExploreNavigationDelegate?
    private var isInSplitViewController: Bool { delegate is SplitViewExploreMapCoordinator }
    
    var searchScreenStyle: SearchScreenStyle = SearchScreenStyle(backgroundColor: .white, searchBarStyle: SearchBarStyle(backgroundColor: .clear, textFieldBackgroundColor: .lsLight2))
    
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
    
    private lazy var searchBarView: SearchBarView = {
        let shouldFillHeight = isInSplitViewController
        let horizontalPadding: CGFloat = isInSplitViewController ? Constants.searchBarHorizontalPaddingiPad : Constants.searchBarHorizontalPaddingiPhone
        return SearchBarView(becomeFirstResponder: false, showGrabberIcon: !isInSplitViewController, shouldFillHeight: shouldFillHeight, horizontalPadding: horizontalPadding)
    }()
    
    var viewModel: SearchViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.accessibilityIdentifier = ViewsIdentifiers.Search.tableView
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = ViewsIdentifiers.Search.searchRootView
        searchBarView.delegate = self
        setupTableView()
        setupViews()
        applyStyles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBarView.makeSearchFirstResponder()
        searchAppearanceChanged(isVisible: true)
        
        if (searchBarView.searchedText() ?? "").isEmpty {
            Task {
                try await viewModel.searchWith(text: "", userLat: nil, userLong: nil)
            }
        } else {
            let mapModels = viewModel.mapModels
            if !mapModels.isEmpty {
                searchResult(mapModel: mapModels, shouldDismiss: false, showOnMap: false)
            }
        }
        changeExploreActionButtonsVisibility()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchAppearanceChanged(isVisible: false)
    }
    
    private func applyStyles() {
        view.backgroundColor = searchScreenStyle.backgroundColor
        tableView.backgroundColor = searchScreenStyle.backgroundColor
        searchBarView.applyStyle(searchScreenStyle.searchBarStyle)
    }
    
    private func searchAppearanceChanged(isVisible: Bool) {
        let userInfo = ["isVisible" : isVisible]
        NotificationCenter.default.post(name: Notification.searchAppearanceChanged, object: nil, userInfo: userInfo)
    }
    
    private func changeExploreActionButtonsVisibility() {
        let userInfo = [
            StringConstant.NotificationsInfoField.geofenceIsHidden: false,
            StringConstant.NotificationsInfoField.directionIsHidden: false
        ]
        NotificationCenter.default.post(name: Notification.exploreActionButtonsVisibilityChanged, object: nil, userInfo: userInfo)
    }
    
    private func clearAnnotations() {
        let coordinates = ["coordinates" : []]
        NotificationCenter.default.post(name: Notification.userLocation, object: nil, userInfo: coordinates)
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        
        if isInSplitViewController {
            let width = view.window?.screen.bounds.width ?? view.frame.width
            searchBarView.snp.makeConstraints {
                $0.width.equalTo(width).priority(.high)
                $0.height.equalTo(Constants.searchBarHeightiPad)
            }
            navigationItem.titleView = searchBarView
        } else {
            view.addSubview(searchBarView)
            searchBarView.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide)
                if isInSplitViewController {
                    $0.height.equalTo(Constants.searchBarHeightiPad)
                } else {
                    $0.height.equalTo(Constants.searchBarHeightiPhone)
                }
                $0.leading.trailing.equalToSuperview()
            }
        }
        
        tableView.snp.makeConstraints {
            if isInSplitViewController {
                $0.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                $0.top.equalTo(searchBarView.snp.bottom).offset(Constants.tableViewTopOffsetiPhone)
            }
            $0.leading.equalToSuperview().offset(Constants.tableViewHorizontalOffset)
            $0.trailing.equalToSuperview().offset(-Constants.tableViewHorizontalOffset)
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
        DispatchQueue.main.async {
            self.isInitalState = (self.searchBarView.searchedText() ?? "").isEmpty
            let coordinates = ["coordinates" : mapModel]
            NotificationCenter.default.post(name: Notification.userLocation, object: nil, userInfo: coordinates)
            
            self.tableView.reloadData()
            if showOnMap {
                self.applyMediumSheetPresentation()
            }
        }
    }
    
    func selectedPlaceResult(mapModel: MapModel) {
        let coordinates = ["place" : mapModel]
        NotificationCenter.default.post(name: Notification.selectedPlace, object: nil, userInfo: coordinates)
    }
}

extension SearchVC: SearchBarViewOutputDelegate {    
    func searchText(_ text: String?) {
        print("|||searchText|||")
        Task {
            print("+++searchText Task+++")
            try await viewModel.searchWithSuggesstion(text: text ?? "", userLat: userLocation?.lat, userLong: userLocation?.long)
        }
    }
    
    func searchTextWith(_ text: String?) {
        Task {
            try await viewModel.searchWith(text: text ?? "", userLat: userLocation?.lat, userLong: userLocation?.long)
        }
    }
    
    func searchCancel() {
        clearAnnotations()
        delegate?.dismissSearchScene()
    }
}
