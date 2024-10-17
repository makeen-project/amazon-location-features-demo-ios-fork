//
//  ExploreMapStyleVC.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
final class ExploreMapStyleVC: UIViewController {
    var dismissHandler: VoidHandler?
    
    var selectedIndex: Int = 0
    var headerView: ExploreMapStyleHeaderView = ExploreMapStyleHeaderView()
    var colorSegment: UISegmentedControl? = nil
    
    var viewModel: ExploreMapStyleViewModelProtocol! {
        didSet {
            viewModel.delegate = self
        }
    }
    
    var tableView: UITableView =  {
       let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHandlers()
        setupTableView()
        setupViews()
        viewModel.loadData()
    }
    
    private func setupHandlers() {
        self.headerView.dismissHandler = { [weak self] in
            self?.dismissHandler?()
        }
    }
    
    private func setupViews() {
        let colorNames = [MapStyleColorType.light.colorName, MapStyleColorType.dark.colorName]
        colorSegment = UISegmentedControl(items: colorNames)
        let colorType = UserDefaultsHelper.getObject(value: MapStyleColorType.self, key: .mapStyleColorType)
        colorSegment!.selectedSegmentIndex = (colorType != nil && colorType! == .dark) ? 1 : 0

        view.backgroundColor = .searchBarBackgroundColor
        self.view.addSubview(headerView)
        self.view.addSubview(colorSegment!)
        self.view.addSubview(tableView)
        
        headerView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        colorSegment?.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(150)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(colorSegment!.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().offset(-5)
            $0.bottom.equalToSuperview()
        }
        
        colorSegment?.addTarget(self, action: #selector(mapColorChanged(_:)), for: .valueChanged)
    }
    
    @objc func mapColorChanged(_ sender: UISegmentedControl) {
        let colorType: MapStyleColorType = sender.selectedSegmentIndex == 1 ? .dark : .light
        UserDefaultsHelper.saveObject(value: colorType, key: .mapStyleColorType)
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
    }
}

extension ExploreMapStyleVC: ExploreMapStyleViewModelOutputDelegate {
    func updateTableView(item: Int) {
        selectedIndex = item
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
