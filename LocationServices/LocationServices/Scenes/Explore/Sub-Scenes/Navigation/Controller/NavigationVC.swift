//
//  NavigationVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class NavigationVC: UIViewController {
    weak var delegate: ExploreNavigationDelegate?
    var viewModel: NavigationVCViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private var navigationHeaderView: NavigationHeaderView = NavigationHeaderView()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .searchBarBackgroundColor
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.accessibilityIdentifier = ViewsIdentifiers.Navigation.navigationRootView
        view.backgroundColor = .searchBarBackgroundColor
        setupNotifications()
        setupTableView()
        setupHandler()
        setupViews()
    }
    
    func setupHandler() {
        navigationHeaderView.dismissHandler = { [weak self] in
            var lat: Double? = nil
            var long: Double? = nil
            if self?.viewModel.firstDestionation?.placeName == StringConstant.myLocation {
                lat = self?.viewModel.firstDestionation?.placeLat
                long = self?.viewModel.firstDestionation?.placeLong
            } else if self?.viewModel.secondDestionation?.placeName == StringConstant.myLocation {
                lat = self?.viewModel.secondDestionation?.placeLat
                long = self?.viewModel.secondDestionation?.placeLong
            }
            
            self?.delegate?.showDirections(isRouteOptionEnabled: true, firstDestionation: self?.viewModel.firstDestionation, secondDestionation: self?.viewModel.secondDestionation, lat: lat, long: long)
            NotificationCenter.default.post(name: Notification.Name("NavigationViewDismissed"), object: nil, userInfo: nil)
        }
    }
    
    private func setupViews() {
        self.view.addSubview(navigationHeaderView)
        self.view.addSubview(tableView)
        navigationHeaderView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(navigationHeaderView.snp.bottom).offset(5)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension NavigationVC: NavigationViewModelOutputDelegate {
    func updateResults() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateNavigationHeaderData()
            self.sendMapViewData()
        }
    }
    
}

private extension NavigationVC {
    func updateNavigationHeaderData() {
        let data = viewModel.getSummaryData()
        self.navigationHeaderView.updateDatas(distance: data?.totalDistance, duration: data?.totalDuration)
    }
    func sendMapViewData() {
        let datas = viewModel.getData()
        if let mapData = datas[safe: 0] {
            var mapHeaderData = (distance: mapData.distance, street: mapData.streetAddress)
            let data: [String: Any] = ["MapViewValues" : mapHeaderData]
            NotificationCenter.default.post(name: Notification.Name("UpdateMapViewValues"), object: nil, userInfo: data)
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationSteps(_:)), name: Notification.Name("NavigationStepsUpdated"), object: nil)
    }
    
    @objc private func updateNavigationSteps(_ notification: Notification) {
        guard let datas = notification.userInfo?["steps"] as? (steps: [NavigationSteps], sumData: (totalDistance: Double, totalDuration: Double)) else { return }
        viewModel.update(steps: datas.steps, summaryData: datas.sumData)
    }
}
