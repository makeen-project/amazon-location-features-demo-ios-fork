//
//  TrackingHistoryVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

final class TrackingHistoryVC: UIViewController {
    
    enum Constants {
        static let titleOffsetiPhone: CGFloat = 27
        static let titleOffsetiPad: CGFloat = 0
    }
    
    private var isiPad = UIDevice.current.userInterfaceIdiom == .pad
    private(set) lazy var headerView: TrackingRouteHeaderView = {
        let titleTopOffset: CGFloat = isiPad ? Constants.titleOffsetiPad : Constants.titleOffsetiPhone
        return TrackingRouteHeaderView(titleTopOffset: titleTopOffset)
    }()
    private let noInternetConnectionView = NoInternetConnectionView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.accessibilityIdentifier = ViewsIdentifiers.Tracking.trackingHistoryScrollView
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let scrollViewContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var deletionView: DeleteTrackingView = {
        let view = DeleteTrackingView()
        view.callback = { [weak self] in
            Task {
                try await self?.viewModel.deleteHistory()
            }
        }
        view.isHidden = true
        return view
    }()
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.accessibilityIdentifier = ViewsIdentifiers.Tracking.trackingHistoryTableView
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 10
        return tableView
    }()
    
    var viewModel: TrackingHistoryViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: Notification.updateMapLayerItems, object: nil, userInfo: nil)
        trackingAppearanceChanged(isVisible: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.resetMapLayerItems, object: nil, userInfo: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        trackingAppearanceChanged(isVisible: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateButtonStyle(_:)), name: Notification.updateStartTrackingButton, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTrackingHistory(_:)), name: Notification.updateTrackingHistory, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(trackingEventReceived(_:)), name: Notification.trackingEvent, object: nil)
        navigationController?.navigationBar.tintColor = .lsTetriary
        
        scrollView.delegate = self
        tableView.delegate = self
        
        setupHandlers()
        setupViews()
        setupTableView()
        
        scrollView.isHidden = !Reachability.shared.isInternetReachable
        noInternetConnectionView.isHidden = Reachability.shared.isInternetReachable
        
        if Reachability.shared.isInternetReachable {
            Task {
                await viewModel.loadData()
            }
        }
    }
    
    @objc private func updateButtonStyle(_ notification: Notification) {
        let state = (notification.userInfo?["state"] as? Bool) ?? false
        updateButtonStyle(state: state)
    }
    
    func updateButtonStyle(state: Bool) {
        guard viewModel !== nil else {
            return
        }
        viewModel.changeTrackingStatus(state)
        self.headerView.updateButtonStyle(isTrackingStarted: state)
        self.view.setNeedsLayout()
    }
    
    
    @objc private func updateTrackingHistory(_ notification: Notification) {
        guard (notification.object as? TrackingHistoryViewModelProtocol) !== viewModel else { return }
        guard let history = notification.userInfo?["history"] as? [TrackingHistoryPresentation] else { return }
        viewModel.setHistory(history)
        reloadTableView()
    }
    
    @objc private func trackingEventReceived(_ notification: Notification) {
        guard let model = notification.userInfo?["trackingEvent"] as? TrackingEventModel else { return }
        
        let eventText: String
        switch model.trackerEventType {
        case .enter:
            eventText = StringConstant.entered
        case .exit:
            eventText = StringConstant.exited
        }
        
        let alertModel = AlertModel(title: model.geofenceId, message: "\(StringConstant.tracker) \(eventText) \(model.geofenceId)", cancelButton: nil)
        showAlert(alertModel)
    }
    
    private func setupHandlers() {
        headerView.trackingButtonHandler = { state in
            if UserDefaultsHelper.getAppState() == .loggedIn {
                if state && self.viewModel.sectionsCount() == 0 {
                    self.scrollView.isHidden = !Reachability.shared.isInternetReachable
                    self.noInternetConnectionView.isHidden = Reachability.shared.isInternetReachable
                    Task {
                        await self.viewModel.loadData()
                    }
                }
                
                NotificationCenter.default.post(name: Notification.updateStartTrackingButton, object: nil, userInfo: ["state": state])
            } else  {
                //shouldn't be a case for now. We don't open it wihout authorized state
            }
        }
        
        headerView.showAlertCallback = showAlert(_:)
        headerView.showAlertControllerCallback = { [weak self] alertController in
            self?.present(alertController, animated: true)
        }
    }
    
    func adjustTableViewHeight() {
        tableView.snp.remakeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            if(isiPad){
                $0.height.equalTo(self.view.snp.height).offset(-350)
            }
            else {
                let contentHeight = min(tableView.contentSize.height+100, UIScreen.main.bounds.height - 400)
                $0.height.equalTo(contentHeight)
            }
        }
    }
    
    private func setupViews() {
        scrollView.isScrollEnabled = false
        view.backgroundColor = .searchBarBackgroundColor
        view.addSubview(headerView)
        view.addSubview(scrollView)
        scrollView.addSubview(scrollViewContentView)
        scrollViewContentView.addSubview(tableView)
        scrollViewContentView.addSubview(deletionView)
        view.addSubview(noInternetConnectionView)
        
        headerView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
        }
        
        scrollViewContentView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            if(isiPad){
                $0.height.equalTo(self.view.snp.height).offset(-350)
            }
            else {
                $0.height.equalTo(scrollView.snp.height)
            }
        }
        
        deletionView.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        noInternetConnectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview()
        }
        
        headerView.updateButtonStyle(isTrackingStarted: viewModel.getTrackingStatus())
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            let isReachedBottom = scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height
            self.tableView.isScrollEnabled = !isReachedBottom
            self.scrollView.isScrollEnabled = isReachedBottom
        } else if scrollView == self.scrollView {
            let isReachedTop = scrollView.contentOffset.y <= 0
            self.tableView.isScrollEnabled = isReachedTop
            self.scrollView.isScrollEnabled = !isReachedTop
        }
        self.scrollView.isScrollEnabled = false
    }
    
    private func trackingAppearanceChanged(isVisible: Bool) {
        let userInfo = ["isVisible" : isVisible]
        NotificationCenter.default.post(name: Notification.trackingAppearanceChanged, object: nil, userInfo: userInfo)
    }
}

extension TrackingHistoryVC: TrackingHistoryViewModelOutputDelegate {
    func stopTracking() {
        
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.deletionView.isHidden = self.viewModel.sectionsCount() == 0
            self.tableView.reloadData()
            self.adjustTableViewHeight()
        }
    }
}
