//
//  NavigationVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import AWSGeoRoutes

final class NavigationVC: UIViewController {
    
    enum Constants {
        static let navigationHeaderHeight: CGFloat = 80
        static let titleLeadingOffset: CGFloat = 16
        static let navigationCellRowHeight: CGFloat = 52
    }
    
    weak var delegate: ExploreNavigationDelegate?
    private var isInSplitViewController: Bool { delegate is SplitViewExploreMapCoordinator }
    
    var viewModel: NavigationVCViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.isDirectionalLockEnabled = true
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private let headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    private var titleLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var titleLabel: LargeTitleLabel = {
        let label = LargeTitleLabel(labelText: StringConstant.routeOverview)
        return label
    }()
    
    private let departStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private let departLabel: LargeTitleLabel = {
        let label = LargeTitleLabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let departAddress: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .searchBarTintColor
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let destinationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private let destinationLabel: LargeTitleLabel = {
        let label = LargeTitleLabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let destinationAddress: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .amazonFont(type: .regular, size: 13)
        label.textColor = .searchBarTintColor
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var navigationHeaderView: NavigationHeaderView = NavigationHeaderView()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isScrollEnabled = false
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
        titleLabelContainer.isHidden = !isInSplitViewController
        navigationHeaderView.isHidden = isInSplitViewController
        navigationHeaderView.update(style: .navigationHeader)
        
        let barButtonItem = UIBarButtonItem(title: nil, image: .arrowUpLeftAndArrowDownRight, target: self, action: #selector(hideScreen))
        barButtonItem.tintColor = .lsPrimary
        navigationItem.leftBarButtonItem = barButtonItem
        changeExploreActionButtonsVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupHandler() {
        navigationHeaderView.dismissHandler = { [weak self] in
            UserDefaultsHelper.save(value: false, key: .isNavigationMode)
            UserDefaultsHelper.removeObject(for: .navigationRoute)
            self?.closeScreen()
            
        }
    }
    
    @objc private func closeScreen() {
        var lat: Double? = nil
        var long: Double? = nil
        if viewModel.firstDestination?.placeName == StringConstant.myLocation {
            lat = viewModel.firstDestination?.placeLat
            long = viewModel.firstDestination?.placeLong
        } else if viewModel.secondDestination?.placeName == StringConstant.myLocation {
            lat = viewModel.secondDestination?.placeLat
            long = viewModel.secondDestination?.placeLong
        }
        
        delegate?.showDirections(isRouteOptionEnabled: true, firstDestination: viewModel.firstDestination, secondDestination: viewModel.secondDestination, lat: lat, long: long)
        delegate?.closeNavigationScene()
    }
    
    @objc private func hideScreen() {
        delegate?.hideNavigationScene()
    }
    
    private func setupViews() {
        view.addSubview(headerStackView)
        headerStackView.addArrangedSubview(titleLabelContainer)
        headerStackView.addArrangedSubview(navigationHeaderView)

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        stackView.addArrangedSubview(departStackView)
        stackView.addArrangedSubview(tableView)
        stackView.addArrangedSubview(destinationStackView)

        titleLabelContainer.addSubview(titleLabel)

        departStackView.addArrangedSubview(departLabel)
        departStackView.addArrangedSubview(departAddress)

        destinationStackView.addArrangedSubview(destinationLabel)
        destinationStackView.addArrangedSubview(destinationAddress)

        headerStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.navigationHeaderHeight)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerStackView.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.width.equalTo(scrollView.snp.width)
            $0.bottom.equalToSuperview().offset(-16)
        }

        navigationHeaderView.snp.makeConstraints {
            $0.height.equalTo(Constants.navigationHeaderHeight)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.titleLeadingOffset)
            $0.top.bottom.trailing.equalToSuperview()
        }

        departStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.titleLeadingOffset)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        tableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
            $0.top.equalTo(departStackView.snp.bottom).offset(16)
        }

        destinationStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.titleLeadingOffset)
            $0.top.equalTo(tableView.snp.bottom).offset(32)
            $0.height.equalTo(44)
        }
    }

    private func adjustTableViewHeight() {
        tableView.layoutIfNeeded()
        let legsCount = viewModel.getData().count
        let height = CGFloat(legsCount) * Constants.navigationCellRowHeight
        tableView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
    }
    
    private func changeExploreActionButtonsVisibility() {
        let userInfo = [
            StringConstant.NotificationsInfoField.geofenceIsHidden: true,
            StringConstant.NotificationsInfoField.mapStyleIsHidden: true,
            StringConstant.NotificationsInfoField.directionIsHidden: true
        ]
        NotificationCenter.default.post(name: Notification.exploreActionButtonsVisibilityChanged, object: nil, userInfo: userInfo)
    }
}

extension NavigationVC: NavigationViewModelOutputDelegate {
    func updateResults() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateNavigationHeaderData()
            self.sendMapViewData()
            // Delay adjusting the tableView height until reloadData completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.adjustTableViewHeight()
            }
        }
    }
}

private extension NavigationVC {
    func updateNavigationHeaderData() {
        let data = viewModel.getSummaryData()
        self.navigationHeaderView.updateDatas(distance: data.totalDistance, duration: data.totalDuration, arrivalTime: data.arrivalTime)
        departLabel.text = viewModel.firstDestination?.placeName
        departAddress.text = viewModel.firstDestination?.placeAddress
        
        destinationLabel.text = viewModel.secondDestination?.placeName
        destinationAddress.text = viewModel.secondDestination?.placeAddress
    }
    func sendMapViewData() {
        let datas = viewModel.getData()
        let index = datas.count > 1 ? 1 : 0
        if let mapData = datas[safe: index] {
            let mapHeaderData = (distance: datas[0].distance, street: mapData.instruction, stepImage: mapData.getStepImage())
            let summaryData = viewModel.getSummaryData()
            let data: [String: Any] = ["MapViewValues" : mapHeaderData, "SummaryData": summaryData]
            NotificationCenter.default.post(name: Notification.Name("UpdateMapViewValues"), object: nil, userInfo: data)
        }
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationSteps(_:)), name: Notification.Name("NavigationStepsUpdated"), object: nil)
    }
    
    @objc private func updateNavigationSteps(_ notification: Notification) {
        guard let route = notification.userInfo?["route"] as? GeoRoutesClientTypes.Route else { return }
        viewModel.update(route: route)
    }
}
