//
//  SideBarVC+TableView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

extension SideBarVC {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SideBarCell.self, forCellReuseIdentifier: SideBarCell.reuseId)
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
    }
}

extension SideBarVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getItemCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideBarCell.reuseId, for: indexPath) as? SideBarCell else {
            fatalError("\(SideBarCell.reuseId) \(String.cellCanNotBeDequed)")
        }
        let data = viewModel.getCellItems(indexPath)
        cell.model = data
        if tableView.indexPathForSelectedRow == nil {
            tableView.selectRow(at: indexPath,
                                animated: true,
                                scrollPosition: .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.getCellItems(indexPath)
        delegate?.showNextScene(type: model.type)
    }
}

extension SideBarVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NumberConstants.sideBarCellHeight
    }
}
