//
//  SettingVC+TableView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

extension SettingsVC {
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.settingCellReuseId)
    }

}

extension SettingsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getItemCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.settingCellReuseId, for: indexPath) as? SettingsCell else {
            fatalError("\(SettingsCell.settingCellReuseId) \(String.cellCanNotBeDequed)")
        }
        let data = viewModel.getCellItems(indexPath)
        cell.data = data
        if UIDevice.current.userInterfaceIdiom == .pad,
           tableView.indexPathForSelectedRow == nil {
            tableView.selectRow(at: indexPath,
                                animated: true,
                                scrollPosition: .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = viewModel.getCellItems(indexPath)
        delegate?.showNextScene(type: data.type)
    }
}

extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
}
