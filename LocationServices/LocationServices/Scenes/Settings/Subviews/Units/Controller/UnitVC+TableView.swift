//
//  UnitVC+TableView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension UnitVC {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CommonSelectableCell.self, forCellReuseIdentifier: CommonSelectableCell.reuseId)
    }
}

extension UnitVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}

extension UnitVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getItemCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommonSelectableCell.reuseId, for: indexPath) as? CommonSelectableCell else {
            fatalError("CommonSelectableCell can't dequeu")
        }
        let data = viewModel.getItemFor(indexPath)
        cell.model = data
        cell.isCellSelected(selectedCell == indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CommonSelectableCell {
            self.selectedCell = indexPath.row
            cell.isCellSelected(true)
            self.viewModel.saveSelectedState(indexPath)
        }
    }
}
