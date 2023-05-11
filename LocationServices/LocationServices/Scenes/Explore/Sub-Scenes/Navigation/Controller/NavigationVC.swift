//
//  NavigationVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

final class NavigationVC: UIViewController {
    weak var delegate: ExploreNavigationDelegate?
    private var isInSplitViewController: Bool { delegate is SplitViewExploreMapCoordinator }
    
    var viewModel: NavigationVCViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        return stackView
    }()
    
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
        navigationHeaderView.isHidden = isInSplitViewController
        title = StringConstant.routeOverview
        
        let barButtonItem = UIBarButtonItem(title: nil, image: .chevronBackward, target: self, action: #selector(closeScreen))
        barButtonItem.tintColor = .lsPrimary
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupHandler() {
        navigationHeaderView.dismissHandler = { [weak self] in
            self?.closeScreen()
        }
    }
    
    @objc private func closeScreen() {
        var lat: Double? = nil
        var long: Double? = nil
        if viewModel.firstDestionation?.placeName == StringConstant.myLocation {
            lat = viewModel.firstDestionation?.placeLat
            long = viewModel.firstDestionation?.placeLong
        } else if viewModel.secondDestionation?.placeName == StringConstant.myLocation {
            lat = viewModel.secondDestionation?.placeLat
            long = viewModel.secondDestionation?.placeLong
        }
        
        delegate?.showDirections(isRouteOptionEnabled: true, firstDestionation: viewModel.firstDestionation, secondDestionation: viewModel.secondDestionation, lat: lat, long: long)
        NotificationCenter.default.post(name: Notification.Name("NavigationViewDismissed"), object: nil, userInfo: nil)
    }
    
    private func setupViews() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(navigationHeaderView)
        stackView.addArrangedSubview(tableView)
        
        stackView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        navigationHeaderView.snp.makeConstraints {
            $0.height.equalTo(80)
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
