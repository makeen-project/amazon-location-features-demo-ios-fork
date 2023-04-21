//
//  AboutVC+TableView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit
import SnapKit

extension AboutVC {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AboutCell.self, forCellReuseIdentifier: AboutCell.reuseId)
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
    }
}

extension AboutVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getItemCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AboutCell.reuseId, for: indexPath) as? AboutCell else {
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

extension AboutVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}
