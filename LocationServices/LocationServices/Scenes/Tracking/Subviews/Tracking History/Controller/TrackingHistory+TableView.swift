//
//  TrackingHistory+TableView.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

extension TrackingHistoryVC {
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.sectionHeaderTopPadding = 0
        self.tableView.register(TrackHistoryCell.self, forCellReuseIdentifier: TrackHistoryCell.reuseId)
        self.tableView.register(TrackingHistorySectionHeaderView.self, forHeaderFooterViewReuseIdentifier: TrackingHistorySectionHeaderView.reuseId)
    }
}

extension TrackingHistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundView = viewModel.sectionsCount() == 0 ? TrackingHistoryEmptyView() : nil
        return viewModel.sectionsCount()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: TrackingHistorySectionHeaderView.reuseId) as? TrackingHistorySectionHeaderView
        view?.title = viewModel.getTitle(for: section)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 57
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getItemCount(for: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackHistoryCell.reuseId, for: indexPath) as? TrackHistoryCell else {
            fatalError(.errorCellCannotBeInititalized)
        }
        let data = viewModel.getCellModel(indexPath: indexPath)
        cell.model = data
        return cell
    }
    
}
