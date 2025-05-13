//
//  LanguageViewController.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

class LanguageViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
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
        label.text = StringConstant.selectLanguage
        label.font = .boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .detailDisclosure)
        button.accessibilityIdentifier = ViewsIdentifiers.General.languageViewCloseButton
        button.setImage(.closeIcon, for: .normal)
        button.tintColor = .closeButtonTintColor
        button.backgroundColor = .closeButtonBackgroundColor
        button.isUserInteractionEnabled = true
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(languageViewDismiss), for: .touchUpInside)
        return button
    }()
    
    var onDismiss: (() -> Void)?
    
    @objc private func languageViewDismiss() {
        self.dismiss(animated: true)
        onDismiss?()
    }
    
    @objc private func clearLanguage() {
        selectedIndexPath = nil
        UserDefaultsHelper.removeObject(for: .language)
        tableView.reloadData()
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .politicalListViewBackgroundColor
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)
        view.addSubview(headerView)
        
        tableView = UITableView(frame: view.bounds)
        tableView.accessibilityIdentifier = ViewsIdentifiers.General.languageViewTable
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LanguageViewCell.self, forCellReuseIdentifier: ViewsIdentifiers.General.languageViewCell)
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
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview().offset(-40)
        }

        
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        

        let language = Locale.currentLanguageIdentifier()
        var selectedIndex = languageSwitcherData.firstIndex(where: { type in
            if type.value == language {
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
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageSwitcherData.count
    }
    
    private var checkedIcon: UIImageView = {
        let image = UIImage.checkMark
        let iv = UIImageView(image: image)
        iv.contentMode = .scaleAspectFill
        iv.tintColor = .mapStyleTintColor
        return iv
    }()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ViewsIdentifiers.General.languageViewCell, for: indexPath) as? LanguageViewCell else {
            return UITableViewCell()
        }
        let language = languageSwitcherData[indexPath.row]
        cell.configure(with: language)
        
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
        UserDefaultsHelper.saveObject(value: languageSwitcherData[indexPath.row], key: .language)
        tableView.reloadData()
        NotificationCenter.default.post(name: Notification.refreshMapView, object: nil, userInfo: nil)
    }
}
