//
//  NavigationVC+TableView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension NavigationVC {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NavigationVCCell.self, forCellReuseIdentifier: NavigationVCCell.reuseId)
    }
}

extension NavigationVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
}

extension NavigationVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getItemCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NavigationVCCell.reuseId, for: indexPath) as? NavigationVCCell else {
            fatalError("NavigationVCCell can't be found")
        }
        let data = viewModel.getData()
        cell.model = data[indexPath.row]
        return cell
    }
}

