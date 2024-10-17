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
        
        let lightImage = GeneralHelper.getImageAndText(image: UIImage(systemName: "sun.max")!, string: colorNames[0], isImageBeforeText: true)
        let darkImage = GeneralHelper.getImageAndText(image: UIImage(systemName: "moon")!, string: colorNames[1], isImageBeforeText: true)
        
        colorSegment?.setImage(lightImage, forSegmentAt: 0)
        colorSegment?.setImage(darkImage, forSegmentAt: 1)
        colorSegment?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: "#018498")], for: .selected)
        colorSegment?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)

        let colorType = UserDefaultsHelper.getObject(value: MapStyleColorType.self, key: .mapStyleColorType)
        colorSegment!.selectedSegmentIndex = (colorType != nil && colorType! == .dark) ? 1 : 0

        view.backgroundColor = .searchBarBackgroundColor
        self.view.addSubview(headerView)
        self.view.addSubview(tableView)
        self.view.addSubview(colorSegment!)
        
        headerView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().offset(-5)
            $0.bottom.equalTo(colorSegment!).offset(20)
        }
        
        colorSegment?.snp.makeConstraints {
            
            $0.centerX.equalToSuperview()
            if UIDevice.current.userInterfaceIdiom == .pad {
                $0.width.equalTo(400)
                $0.bottom.equalToSuperview().offset(-20)
            }
            else {
                $0.width.equalToSuperview().offset(-50)
                $0.bottom.equalToSuperview().offset(-5)
            }
            $0.height.equalTo(40)
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
