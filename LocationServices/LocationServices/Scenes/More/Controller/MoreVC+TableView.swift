//
//  MoreVC+TableView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

extension MoreVC {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MoreCell.self, forCellReuseIdentifier: MoreCell.reuseId)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
    }
}

extension MoreVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getItemCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MoreCell.reuseId, for: indexPath) as? MoreCell else {
            fatalError("Settings Cell can't be deque")
        }
        let data = viewModel.getCellItems(indexPath)
        cell.model = data
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.getCellItems(indexPath)
        delegate?.showNextScene(type: model.type)
    }
}

extension MoreVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}
