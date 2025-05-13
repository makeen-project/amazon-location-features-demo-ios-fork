//
//  PoliticalViewController.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

class PoliticalViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var filteredPoliticalViews: [PoliticalViewType] = []
    var selectedIndexPath: IndexPath?
    var tableView: UITableView!
    private var isSearching: Bool = false
    
    private var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = StringConstant.politicalView
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .detailDisclosure)
        button.accessibilityIdentifier = ViewsIdentifiers.General.politicalViewCloseButton
        button.setImage(.closeIcon, for: .normal)
        button.tintColor = .closeButtonTintColor
        button.backgroundColor = .closeButtonBackgroundColor
        button.isUserInteractionEnabled = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(politicalViewDismiss), for: .touchUpInside)
        return button
    }()
    
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.image(for: .search, state: .normal)
        searchBar.backgroundColor = .clear
        searchBar.searchTextField.backgroundColor = .white
        searchBar.searchTextField.borderStyle = .none
        searchBar.layer.borderWidth = 0
        return searchBar
    }()
    
    var onDismiss: (() -> Void)?
    
    @objc private func politicalViewDismiss() {
        self.dismiss(animated: true)
        onDismiss?()
    }
    
    @objc private func clearPoliticalView() {
        selectedIndexPath = nil
        UserDefaultsHelper.removeObject(for: .politicalView)
        tableView.reloadData()
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .politicalListViewBackgroundColor
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)
        view.addSubview(headerView)
        
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        tableView = UITableView(frame: view.bounds)
        tableView.accessibilityIdentifier = ViewsIdentifiers.General.politicalViewTable
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PoliticalViewCell.self, forCellReuseIdentifier: ViewsIdentifiers.General.politicalViewCell)
        view.addSubview(tableView)
        
        headerView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.equalTo(50)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-11)
            $0.height.width.equalTo(30)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.equalTo(60)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview().offset(-40)
        }
        
        searchBar.backgroundColor = .clear
        searchBar.layer.cornerRadius = 10
        searchBar.layer.masksToBounds = true
        
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        
        filteredPoliticalViews = PoliticalViewTypes
        
        let politicalViewType = UserDefaultsHelper.getObject(value: PoliticalViewType.self, key: .politicalView)
        var selectedIndex = filteredPoliticalViews.firstIndex(where: { type in
            if type.countryCode == politicalViewType?.countryCode {
                return true
            }
            return false
        })
        if selectedIndex == nil {
            selectedIndex = 0
        }
        selectedIndexPath = selectedIndex != nil ? IndexPath(row: selectedIndex!, section: 0) : nil
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPoliticalViews.count
    }
    
    private var checkedIcon: UIImageView = {
        let image = UIImage(systemName: "checkmark")
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .mapStyleTintColor
        return iv
    }()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ViewsIdentifiers.General.politicalViewCell, for: indexPath) as? PoliticalViewCell else {
            return UITableViewCell()
        }
        let politicalView = filteredPoliticalViews[indexPath.row]
        cell.configure(with: politicalView)
        
        if let selectedIndexPath = selectedIndexPath, selectedIndexPath == indexPath {
            cell.accessoryView = checkedIcon
        } else {
            cell.accessoryView = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndexPath = indexPath
        if selectedIndexPath?.row == 0 {
            UserDefaultsHelper.removeObject(for: .politicalView)
        }
        else {
            UserDefaultsHelper.saveObject(value: filteredPoliticalViews[indexPath.row], key: .politicalView)
        }
        tableView.reloadData()
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterPoliticalViews(for: searchText)
    }
    
    private func filterPoliticalViews(for query: String) {
        if query.isEmpty {
            isSearching = false
            filteredPoliticalViews = PoliticalViewTypes
        } else {
            isSearching = true
            filteredPoliticalViews = PoliticalViewTypes.filter {
                $0.countryCode.lowercased().contains(query.lowercased()) ||
                $0.fullName.lowercased().contains(query.lowercased()) ||
                $0.politicalDescription.lowercased().contains(query.lowercased())
            }
        }
        tableView.reloadData()
    }
}
